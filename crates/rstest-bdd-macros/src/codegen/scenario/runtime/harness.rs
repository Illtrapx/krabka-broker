//! Token assembly for harness-delegated scenario execution.
//!
//! When a harness adapter type is specified via the `harness` parameter, the
//! runtime portion of the test (context setup, step executor loop, skip handler,
//! postlude, and user block) is wrapped in a closure passed to
//! `HarnessAdapter::run()`. Item definitions (constants, inner functions,
//! structs) remain outside the closure because they are Rust items visible by
//! name resolution, not captured variables.

use proc_macro2::TokenStream as TokenStream2;
use quote::quote;

use super::types::{CodeComponents, ScenarioLiterals, TokenAssemblyContext};

/// Generates the const/static metadata declarations and item definitions
/// (step executor, skip extractor, scenario guard) that live outside the
/// runner closure.
fn generate_metadata_constants(
    literals: &ScenarioLiterals,
    components: &CodeComponents,
) -> TokenStream2 {
    // Deliberately exhaustive (no `..` rest): a future field addition to
    // `ScenarioLiterals` must be a hard error here, not a silent omission
    // (ExecPlan Milestone 6). The value expressions are consumed by the
    // runner closure and the harness metadata, not by these item
    // declarations, so they are bound with leading underscores.
    let ScenarioLiterals {
        feature_literal,
        scenario_literal,
        scenario_line_literal,
        tag_items,
        tags_value: _tags_value,
        tags_vec: _tags_vec,
        allow_value: _allow_value,
        expected_failure_value: _expected_failure_value,
    } = literals;
    let CodeComponents {
        step_executor,
        skip_extractor,
        scenario_guard,
        ..
    } = components;

    quote! {
        const __RSTEST_BDD_FEATURE_PATH: &str = #feature_literal;
        const __RSTEST_BDD_SCENARIO_NAME: &str = #scenario_literal;
        const __RSTEST_BDD_SCENARIO_LINE: u32 = #scenario_line_literal;
        #tag_items

        #step_executor
        #skip_extractor
        #scenario_guard
    }
}

/// Parameters for generating the runner closure body.
#[derive(Clone, Copy)]
struct RunnerClosureParams<'a> {
    /// Expression yielding whether the scenario may be skipped.
    allow_value: &'a TokenStream2,
    /// Expression yielding the scenario's `ScenarioTags`.
    tags_value: &'a TokenStream2,
    /// Stores the internal `ctx_prelude` value.
    ctx_prelude: &'a [TokenStream2],
    /// Stores the internal `ctx_inserts` value.
    ctx_inserts: &'a [TokenStream2],
    /// Stores the internal `ctx_postlude` value.
    ctx_postlude: &'a [TokenStream2],
    /// Stores the internal `block` value.
    block: &'a TokenStream2,
    /// Stores the internal `step_executor_loop` value.
    step_executor_loop: &'a TokenStream2,
    /// Stores the internal `skip_handler` value.
    skip_handler: &'a TokenStream2,
    /// Expression yielding the expected-failure reason, if any.
    expected_failure_value: &'a TokenStream2,
    /// Panics or returns after a failed step.
    failure_handler: &'a TokenStream2,
    /// Fails an expected-failure scenario whose steps all passed.
    expected_failure_check: &'a TokenStream2,
    /// Stores the internal `path` value.
    path: &'a TokenStream2,
    /// Stores the internal `harness_context_ty` value.
    harness_context_ty: &'a TokenStream2,
}

/// Generates the body of the `ScenarioRunner` closure: context setup, step
/// execution loop, skip handling, postlude, and the user block.
fn generate_runner_closure_body(params: RunnerClosureParams<'_>) -> TokenStream2 {
    let RunnerClosureParams {
        allow_value,
        tags_value,
        ctx_prelude,
        ctx_inserts,
        ctx_postlude,
        block,
        step_executor_loop,
        skip_handler,
        expected_failure_value,
        failure_handler,
        expected_failure_check,
        path,
        harness_context_ty,
    } = params;

    quote! {
        let __rstest_bdd_allow_skipped: bool = #allow_value;
        let __rstest_bdd_expected_failure: Option<&str> = #expected_failure_value;
        #(#ctx_prelude)*
        let __rstest_bdd_harness_context_cell =
            #path::StepContext::owned_cell(__rstest_bdd_harness_context);
        let mut ctx = {
            let mut ctx = #path::StepContext::default();
            #(#ctx_inserts)*
            ctx.insert_owned_harness_context::<#harness_context_ty>(
                &__rstest_bdd_harness_context_cell
            );
            ctx
        };

        let mut __rstest_bdd_scenario_guard = __RstestBddScenarioReportGuard::new(
            __RSTEST_BDD_FEATURE_PATH,
            __RSTEST_BDD_SCENARIO_NAME,
            __RSTEST_BDD_SCENARIO_LINE,
            #tags_value,
        );
        let mut __rstest_bdd_skipped: Option<Option<String>> = None;
        let mut __rstest_bdd_skipped_at: Option<usize> = None;
        #step_executor_loop
        #failure_handler
        #skip_handler
        #expected_failure_check
        #(#ctx_postlude)*
        #block
    }
}

/// The resolved harness paths threaded through harness token assembly.
///
/// Grouping the adapter type path with the harness API crate path keeps them
/// travelling together: both come from the same harness resolution step, and
/// mixing a path from one resolution with a crate path from another would
/// generate tokens that name a type in the wrong crate.
#[derive(Debug, Clone, Copy)]
pub(super) struct HarnessAssemblyPaths<'a> {
    /// Path to the user-supplied `HarnessAdapter` implementor.
    pub(super) harness_path: &'a syn::Path,
    /// Tokens naming the harness API crate the adapter's traits resolve in.
    pub(super) harness_crate: &'a TokenStream2,
}
/// Assembles test tokens with harness delegation.
pub(super) fn assemble_test_tokens_with_harness(
    literals: &ScenarioLiterals,
    components: &CodeComponents,
    context: TokenAssemblyContext<'_>,
    harness: HarnessAssemblyPaths<'_>,
) -> TokenStream2 {
    let HarnessAssemblyPaths {
        harness_path,
        harness_crate,
    } = harness;
    let path = crate::codegen::rstest_bdd_path();
    let harness_context_ty = quote! {
        <#harness_path as #harness_crate::HarnessAdapter>::Context
    };

    let constants = generate_metadata_constants(literals, components);
    let closure_body = generate_runner_closure_body(RunnerClosureParams {
        allow_value: &literals.allow_value,
        tags_value: &literals.tags_value,
        ctx_prelude: context.ctx_prelude,
        ctx_inserts: context.ctx_inserts,
        ctx_postlude: context.ctx_postlude,
        block: context.block,
        step_executor_loop: &components.step_executor_loop,
        skip_handler: &components.skip_handler,
        expected_failure_value: &literals.expected_failure_value,
        failure_handler: &components.failure_handler,
        expected_failure_check: &components.expected_failure_check,
        path: &path,
        harness_context_ty: &harness_context_ty,
    });

    let tags_vec = &literals.tags_vec;

    quote! {
        #constants

        let __rstest_bdd_harness_metadata = #harness_crate::ScenarioMetadata::new(
            __RSTEST_BDD_FEATURE_PATH,
            __RSTEST_BDD_SCENARIO_NAME,
            __RSTEST_BDD_SCENARIO_LINE,
            #tags_vec,
        );

        let __rstest_bdd_runner = #harness_crate::ScenarioRunner::new(
            move |__rstest_bdd_harness_context: <#harness_path as #harness_crate::HarnessAdapter>::Context| {
                #closure_body
            }
        );

        let __rstest_bdd_request = #harness_crate::ScenarioRunRequest::new(
            __rstest_bdd_harness_metadata,
            __rstest_bdd_runner,
        );

        let __rstest_bdd_harness = <#harness_path as Default>::default();
        <#harness_path as #harness_crate::HarnessAdapter>::run(
            &__rstest_bdd_harness,
            __rstest_bdd_request,
        )
        .unwrap_or_else(|err| {
            let feature_path = __RSTEST_BDD_FEATURE_PATH;
            let scenario_name = __RSTEST_BDD_SCENARIO_NAME;
            let harness_type = std::any::type_name::<#harness_path>();
            let err = err.with_scenario_context(feature_path, scenario_name);
            #harness_crate::tracing::error!(
                %harness_type,
                %feature_path,
                %scenario_name,
                %err,
                "harness failed to initialize scenario"
            );
            panic!("harness failed to initialize scenario: {err}")
        })
    }
}
