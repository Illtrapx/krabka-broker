//! Parses arguments supplied to the `scenarios!` macro.
//!
//! Accepts either a positional directory literal or the `dir = "..."` and
//! `path = "..."` named arguments alongside an optional `tags = "..."` filter,
//! an optional `ignore_tags = "..."` expression, an optional `fixtures = [name: Type, ...]` list,
//! and an optional `runtime = "..."` mode selection.
//! The parser enforces that each input appears at most once, mirroring both
//! accepted spellings in duplicate and missing-argument diagnostics so users
//! immediately see which synonym needs adjusting.
//!
//! `RuntimeMode` and `TestAttributeHint` are imported from
//! `rstest_bdd_policy`, matching the runtime crate's public re-exports.
//! Regression tests in this module and in `rstest-bdd::execution` guard that
//! shared source of truth so macro/runtime policy semantics do not drift.

pub(crate) use rstest_bdd_policy::{RuntimeMode, TestAttributeHint};
use syn::{
    LitStr,
    parse::{Parse, ParseStream},
    punctuated::Punctuated,
    token::Comma,
};

/// Compatibility aliases that map legacy runtime syntax to harness selection.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(super) enum RuntimeCompatibilityAlias {
    /// Compatibility alias for the Tokio harness adapter path.
    TokioHarnessAdapter,
}

/// Provides the internal `fn` operation.
pub(super) const fn runtime_compatibility_alias(
    runtime: RuntimeMode,
) -> Option<RuntimeCompatibilityAlias> {
    match runtime {
        RuntimeMode::Sync => None,
        RuntimeMode::TokioCurrentThread => Some(RuntimeCompatibilityAlias::TokioHarnessAdapter),
    }
}

/// A single fixture specification: `name: Type`.
#[derive(Clone, Debug)]
pub(super) struct FixtureSpec {
    /// Stores the internal `name` value.
    pub(super) name: syn::Ident,
    /// Stores the internal `ty` value.
    pub(super) ty: syn::Type,
}

impl Parse for FixtureSpec {
    fn parse(input: ParseStream<'_>) -> syn::Result<Self> {
        let name: syn::Ident = input.parse()?;
        input.parse::<syn::token::Colon>()?;
        let ty: syn::Type = input.parse()?;
        Ok(Self { name, ty })
    }
}

/// Internal data used by the macros implementation.
pub(super) struct ScenariosArgs {
    /// Stores the internal `dir` value.
    pub(super) dir: LitStr,
    /// Stores the internal `tag_filter` value.
    pub(super) tag_filter: Option<LitStr>,
    /// Tag expression whose matching scenarios and rows are generated with
    /// `#[ignore]` instead of being dropped.
    pub(super) ignore_tags: Option<LitStr>,
    /// Stores the internal `fixtures` value.
    pub(super) fixtures: Vec<FixtureSpec>,
    /// Stores the internal `runtime` value.
    pub(super) runtime: RuntimeMode,
    /// Stores the internal `harness` value.
    pub(super) harness: Option<syn::Path>,
    /// Stores the internal `attributes` value.
    pub(super) attributes: Option<syn::Path>,
}

/// Documents the internal `ScenariosArg` item.
enum ScenariosArg {
    /// Represents the internal validation outcome.
    Dir(LitStr),
    /// Represents the internal validation outcome.
    Tags(LitStr),
    /// The `ignore_tags = "..."` expression.
    IgnoreTags(LitStr),
    /// Represents the internal validation outcome.
    Fixtures(Vec<FixtureSpec>),
    /// Represents the internal validation outcome.
    Runtime(RuntimeMode),
    /// Represents the internal validation outcome.
    Harness(syn::Path),
    /// Represents the internal validation outcome.
    Attributes(syn::Path),
}

impl Parse for ScenariosArg {
    fn parse(input: ParseStream<'_>) -> syn::Result<Self> {
        if input.peek(LitStr) {
            Ok(Self::Dir(input.parse()?))
        } else {
            let ident: syn::Ident = input.parse()?;
            input.parse::<syn::token::Eq>()?;
            parse_named_arg(&ident, input)
        }
    }
}

/// Parse a named argument based on its identifier.
fn parse_named_arg(ident: &syn::Ident, input: ParseStream<'_>) -> syn::Result<ScenariosArg> {
    match ident.to_string().as_str() {
        "dir" | "path" => Ok(ScenariosArg::Dir(input.parse()?)),
        "tags" => Ok(ScenariosArg::Tags(input.parse()?)),
        "ignore_tags" => Ok(ScenariosArg::IgnoreTags(input.parse()?)),
        "fixtures" => parse_fixtures_arg(input),
        "runtime" => parse_runtime_arg(input),
        "harness" => Ok(ScenariosArg::Harness(input.parse()?)),
        "attributes" => Ok(ScenariosArg::Attributes(input.parse()?)),
        _ => Err(input.error(concat!(
            "expected `dir`, `path`, `tags`, `ignore_tags`, `fixtures`, `runtime`, `harness`, ",
            "or `attributes`",
        ))),
    }
}

/// Parse the fixtures argument: `fixtures = [name: Type, ...]`
fn parse_fixtures_arg(input: ParseStream<'_>) -> syn::Result<ScenariosArg> {
    let content;
    syn::bracketed!(content in input);
    let specs = Punctuated::<FixtureSpec, Comma>::parse_terminated(&content)?;
    Ok(ScenariosArg::Fixtures(specs.into_iter().collect()))
}

/// Parse the runtime argument: `runtime = "tokio-current-thread"`
fn parse_runtime_arg(input: ParseStream<'_>) -> syn::Result<ScenariosArg> {
    let value: LitStr = input.parse()?;
    let mode = parse_runtime_mode(&value)?;
    Ok(ScenariosArg::Runtime(mode))
}

/// Parse a runtime mode string into a `RuntimeMode` enum.
fn parse_runtime_mode(value: &LitStr) -> syn::Result<RuntimeMode> {
    match value.value().as_str() {
        "tokio-current-thread" => Ok(RuntimeMode::TokioCurrentThread),
        other => Err(syn::Error::new(
            value.span(),
            format!("unknown runtime `{other}`; supported: \"tokio-current-thread\""),
        )),
    }
}

/// Assign `value` to `slot` if empty, or return a duplicate-argument error.
fn set_once<T>(
    slot: &mut Option<T>,
    value: T,
    label: &str,
    input: ParseStream<'_>,
) -> syn::Result<()> {
    if slot.is_some() {
        return Err(input.error(format!("duplicate `{label}` argument")));
    }
    *slot = Some(value);
    Ok(())
}

/// Arguments collected while parsing, before defaults are applied.
#[derive(Default)]
struct ArgSlots {
    /// The `dir`/`path` argument.
    dir: Option<LitStr>,
    /// The `tags` argument.
    tag_filter: Option<LitStr>,
    /// The `ignore_tags` argument.
    ignore_tags: Option<LitStr>,
    /// The `fixtures` argument.
    fixtures: Option<Vec<FixtureSpec>>,
    /// The `runtime` argument.
    runtime: Option<RuntimeMode>,
    /// The `harness` argument.
    harness: Option<syn::Path>,
    /// The `attributes` argument.
    attributes: Option<syn::Path>,
}

/// Process each parsed argument and populate the corresponding field.
fn process_args(
    args: Punctuated<ScenariosArg, Comma>,
    input: ParseStream<'_>,
) -> syn::Result<ArgSlots> {
    let mut slots = ArgSlots::default();
    for arg in args {
        match arg {
            ScenariosArg::Dir(lit) => set_once(&mut slots.dir, lit, "dir/path", input)?,
            ScenariosArg::Tags(lit) => set_once(&mut slots.tag_filter, lit, "tags", input)?,
            ScenariosArg::IgnoreTags(lit) => {
                set_once(&mut slots.ignore_tags, lit, "ignore_tags", input)?;
            }
            ScenariosArg::Fixtures(specs) => {
                set_once(&mut slots.fixtures, specs, "fixtures", input)?;
            }
            ScenariosArg::Runtime(mode) => set_once(&mut slots.runtime, mode, "runtime", input)?,
            ScenariosArg::Harness(p) => set_once(&mut slots.harness, p, "harness", input)?,
            ScenariosArg::Attributes(p) => {
                set_once(&mut slots.attributes, p, "attributes", input)?;
            }
        }
    }
    Ok(slots)
}

impl Parse for ScenariosArgs {
    fn parse(input: ParseStream<'_>) -> syn::Result<Self> {
        let args = Punctuated::<ScenariosArg, Comma>::parse_terminated(input)?;
        let slots = process_args(args, input)?;
        let dir = slots
            .dir
            .ok_or_else(|| input.error("`dir` (or `path`) argument is required"))?;

        Ok(Self {
            dir,
            tag_filter: slots.tag_filter,
            ignore_tags: slots.ignore_tags,
            fixtures: slots.fixtures.unwrap_or_default(),
            runtime: slots.runtime.unwrap_or_default(),
            harness: slots.harness,
            attributes: slots.attributes,
        })
    }
}

#[cfg(test)]
mod tests;
