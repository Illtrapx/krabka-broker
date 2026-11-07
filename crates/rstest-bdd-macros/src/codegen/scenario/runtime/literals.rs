//! Scenario metadata literals embedded in generated test bodies.
//!
//! A plain scenario has one tag set and one `@allow_skipped` decision. A
//! Scenario Outline row also inherits the tags of the Examples block that
//! declared it, so each generated case must report its own tags and apply
//! its own skip policy. For outlines the tags and skip flags are therefore
//! emitted as per-row tables, selected at run time by the hidden
//! `__rstest_bdd_case_idx` case parameter. The same holds for the
//! `expect_failure_tags` decision, which is emitted as an optional reason per
//! scenario or per row.

use proc_macro2::TokenStream as TokenStream2;
use quote::quote;

use super::types::{ScenarioLiterals, ScenarioLiteralsInput};
use crate::codegen::scenario::{scenario_allows_skip, tag_policy::expected_failure_reason};

/// Convert scenario metadata into literals embedded in generated test tokens.
pub(super) fn create_scenario_literals(input: ScenarioLiteralsInput<'_>) -> ScenarioLiterals {
    let span = proc_macro2::Span::call_site();
    let tags = input.row_tags.map_or_else(
        || scenario_tags(input.tags, input.allow_skipped),
        outline_row_tags,
    );
    let (failure_items, expected_failure_value) = expected_failure_tokens(input);
    let tag_items = tags.items;
    ScenarioLiterals {
        feature_literal: syn::LitStr::new(input.feature_path.as_str(), span),
        scenario_literal: syn::LitStr::new(input.scenario_name.as_str(), span),
        scenario_line_literal: syn::LitInt::new(&input.scenario_line.to_string(), span),
        tag_items: quote! { #tag_items #failure_items },
        tags_value: tags.value,
        tags_vec: tags.vec,
        allow_value: tags.allow,
        expected_failure_value,
    }
}

/// Render an optional expected-failure reason as an `Option<&str>` expression.
fn reason_tokens(reason: Option<String>) -> TokenStream2 {
    reason.map_or_else(|| quote! { None }, |reason| quote! { Some(#reason) })
}

/// Item declarations and the expression yielding this test's expected-failure
/// reason, selected per row for outlines.
fn expected_failure_tokens(input: ScenarioLiteralsInput<'_>) -> (TokenStream2, TokenStream2) {
    let policy = input.expect_failure_tags;
    let Some(row_tags) = input.row_tags else {
        return (
            TokenStream2::new(),
            reason_tokens(expected_failure_reason(policy, input.tags)),
        );
    };
    let reasons = row_tags
        .iter()
        .map(|tags| reason_tokens(expected_failure_reason(policy, tags)));
    (
        quote! {
            const __RSTEST_BDD_EXPECTED_FAILURE_ROWS: &[Option<&str>] = &[#(#reasons),*];
        },
        quote! {
            __RSTEST_BDD_EXPECTED_FAILURE_ROWS
                .get(__rstest_bdd_case_idx)
                .copied()
                .flatten()
        },
    )
}

/// Tag-related tokens for one generated test function.
struct TagTokens {
    /// Item declarations backing the expressions below.
    items: TokenStream2,
    /// Expression yielding the case's `ScenarioTags`.
    value: TokenStream2,
    /// Expression yielding the case's tags as `Vec<String>`.
    vec: TokenStream2,
    /// Expression yielding whether the case may be skipped.
    allow: TokenStream2,
}

/// Build string literals for a tag set.
fn tag_literals(tags: &[String]) -> Vec<syn::LitStr> {
    tags.iter()
        .map(|tag| syn::LitStr::new(tag, proc_macro2::Span::call_site()))
        .collect()
}

/// Tag tokens for a scenario with a single tag set.
fn scenario_tags(tags: &[String], allow_skipped: bool) -> TagTokens {
    let path = crate::codegen::rstest_bdd_path();
    let literals = tag_literals(tags);
    let allow_literal = syn::LitBool::new(allow_skipped, proc_macro2::Span::call_site());
    TagTokens {
        items: quote! {
            static __RSTEST_BDD_SCENARIO_TAGS: std::sync::LazyLock<#path::reporting::ScenarioTags> =
                std::sync::LazyLock::new(|| {
                    std::sync::Arc::<[String]>::from(vec![#(#literals.to_string()),*])
                });
        },
        value: quote! { __RSTEST_BDD_SCENARIO_TAGS.clone() },
        vec: quote! { vec![#(#literals.to_string()),*] },
        allow: quote! { #allow_literal },
    }
}

/// Tag tokens for an outline, with one tag set and skip flag per Examples row.
fn outline_row_tags(row_tags: &[Vec<String>]) -> TagTokens {
    let path = crate::codegen::rstest_bdd_path();
    let rows = row_tags.iter().map(|tags| {
        let literals = tag_literals(tags);
        quote! { std::sync::Arc::<[String]>::from(vec![#(#literals.to_string()),*]) }
    });
    let allow_flags = row_tags
        .iter()
        .map(|tags| syn::LitBool::new(scenario_allows_skip(tags), proc_macro2::Span::call_site()));
    TagTokens {
        items: quote! {
            static __RSTEST_BDD_SCENARIO_TAG_ROWS:
                std::sync::LazyLock<Vec<#path::reporting::ScenarioTags>> =
                std::sync::LazyLock::new(|| vec![#(#rows),*]);
            const __RSTEST_BDD_ALLOW_SKIPPED_ROWS: &[bool] = &[#(#allow_flags),*];
        },
        value: quote! { __RSTEST_BDD_SCENARIO_TAG_ROWS[__rstest_bdd_case_idx].clone() },
        vec: quote! { __RSTEST_BDD_SCENARIO_TAG_ROWS[__rstest_bdd_case_idx].to_vec() },
        allow: quote! { __RSTEST_BDD_ALLOW_SKIPPED_ROWS[__rstest_bdd_case_idx] },
    }
}

#[cfg(test)]
mod tests {
    //! Unit tests for per-row outline tag literals.

    use super::*;

    #[test]
    fn outline_rows_carry_their_own_tags_and_skip_policy() {
        let rows = vec![
            vec!["@outline".to_owned()],
            vec!["@outline".to_owned(), "@allow_skipped".to_owned()],
        ];
        let tokens = outline_row_tags(&rows);
        let items = tokens.items.to_string();
        assert!(
            items.contains("& [false , true]"),
            "skip flags should follow each row's tags: {items}"
        );
        assert!(
            items.contains("\"@allow_skipped\""),
            "row tags should be embedded: {items}"
        );
        assert!(
            tokens.allow.to_string().contains("__rstest_bdd_case_idx"),
            "skip policy should be selected by case index"
        );
    }

    #[test]
    fn scenarios_keep_a_single_tag_set() {
        let tokens = scenario_tags(&["@fast".to_owned()], true);
        assert_eq!(tokens.allow.to_string(), "true");
        assert!(
            tokens
                .items
                .to_string()
                .contains("__RSTEST_BDD_SCENARIO_TAGS")
        );
    }
}
