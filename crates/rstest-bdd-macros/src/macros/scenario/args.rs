//! Argument parsing for `#[scenario]` covering required `path`, mutually
//! exclusive `index`/`name` selectors, optional tag filters, an optional
//! `ignore_tags` and `expect_failure_tags` expressions, and optional
//! harness adapter and attribute policy paths. Reports duplicates and
//! conflicts with combined `syn::Error`s.

use proc_macro2::Span;
use syn::{
    LitInt,
    LitStr,
    parse::{Parse, ParseStream},
    punctuated::Punctuated,
    token::Comma,
};

/// Internal data used by the macros implementation.
pub(super) struct ScenarioArgs {
    /// Stores the internal `path` value.
    pub(super) path: LitStr,
    /// Stores the internal `selector` value.
    pub(super) selector: Option<ScenarioSelector>,
    /// Stores the internal `tag_filter` value.
    pub(super) tag_filter: Option<LitStr>,
    /// Tag expression that marks the selected scenario or rows `#[ignore]`.
    pub(super) ignore_tags: Option<LitStr>,
    /// Tag expression that runs the selected scenario or rows as expected failures.
    pub(super) expect_failure_tags: Option<LitStr>,
    /// Stores the internal `harness` value.
    pub(super) harness: Option<syn::Path>,
    /// Stores the internal `attributes` value.
    pub(super) attributes: Option<syn::Path>,
}

/// Documents the internal `ScenarioSelector` item.
pub(super) enum ScenarioSelector {
    /// Represents the internal validation outcome.
    Index {
        /// Zero-based scenario index.
        value: usize,
        /// Source span of the index argument.
        span: Span,
    },
    /// Represents the internal validation outcome.
    Name {
        /// Scenario name selected by the argument.
        value: String,
        /// Source span of the name argument.
        span: Span,
    },
}

/// Documents the internal `ScenarioArg` item.
enum ScenarioArg {
    /// Represents the internal validation outcome.
    Path(LitStr),
    /// Represents the internal validation outcome.
    Index(LitInt),
    /// Represents the internal validation outcome.
    Name(LitStr),
    /// Represents the internal validation outcome.
    Tags(LitStr),
    /// The `ignore_tags = "..."` expression.
    IgnoreTags(LitStr),
    /// The `expect_failure_tags = "..."` expression.
    ExpectFailureTags(LitStr),
    /// Represents the internal validation outcome.
    Harness(syn::Path),
    /// Represents the internal validation outcome.
    Attributes(syn::Path),
}

impl Parse for ScenarioArg {
    fn parse(input: ParseStream<'_>) -> syn::Result<Self> {
        if input.peek(LitStr) {
            let lit: LitStr = input.parse()?;
            Ok(Self::Path(lit))
        } else {
            let ident: syn::Ident = input.parse()?;
            input.parse::<syn::token::Eq>()?;
            if ident == "path" {
                Ok(Self::Path(input.parse()?))
            } else if ident == "index" {
                Ok(Self::Index(input.parse()?))
            } else if ident == "name" {
                Ok(Self::Name(input.parse()?))
            } else if ident == "tags" {
                Ok(Self::Tags(input.parse()?))
            } else if ident == "ignore_tags" {
                Ok(Self::IgnoreTags(input.parse()?))
            } else if ident == "expect_failure_tags" {
                Ok(Self::ExpectFailureTags(input.parse()?))
            } else if ident == "harness" {
                Ok(Self::Harness(input.parse()?))
            } else if ident == "attributes" {
                Ok(Self::Attributes(input.parse()?))
            } else {
                Err(input.error(concat!(
                    "expected `path`, `index`, `name`, `tags`, `ignore_tags`, ",
                    "`expect_failure_tags`, `harness`, or ",
                    "`attributes`",
                )))
            }
        }
    }
}

impl Parse for ScenarioArgs {
    fn parse(input: ParseStream<'_>) -> syn::Result<Self> {
        let args = Punctuated::<ScenarioArg, Comma>::parse_terminated(input)?;
        let mut path = None;
        let mut selector = None;
        let mut tag_filter = None;
        let mut ignore_tags = None;
        let mut expect_failure_tags = None;
        let mut harness = None;
        let mut attributes = None;

        for arg in args {
            match arg {
                ScenarioArg::Path(lit) => set_unique_field(&mut path, lit, "path", input)?,
                ScenarioArg::Index(i) => set_selector_index(&mut selector, &i)?,
                ScenarioArg::Name(lit) => set_selector_name(&mut selector, &lit)?,
                ScenarioArg::Tags(lit) => set_unique_field(&mut tag_filter, lit, "tags", input)?,
                ScenarioArg::IgnoreTags(lit) => {
                    set_unique_field(&mut ignore_tags, lit, "ignore_tags", input)?;
                }
                ScenarioArg::ExpectFailureTags(lit) => {
                    let label = "expect_failure_tags";
                    set_unique_field(&mut expect_failure_tags, lit, label, input)?;
                }
                ScenarioArg::Harness(p) => {
                    set_unique_field(&mut harness, p, "harness", input)?;
                }
                ScenarioArg::Attributes(p) => {
                    set_unique_field(&mut attributes, p, "attributes", input)?;
                }
            }
        }

        let path = path.ok_or_else(|| input.error("`path` argument is required"))?;

        Ok(Self {
            path,
            selector,
            tag_filter,
            ignore_tags,
            expect_failure_tags,
            harness,
            attributes,
        })
    }
}

/// Assign `value` to `slot` if empty, or return a duplicate-argument error.
fn set_unique_field<T>(
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

/// Generic helper to set a selector after checking for conflicts.
fn set_selector<F>(
    selector: &mut Option<ScenarioSelector>,
    kind: SelectorKind,
    span: Span,
    build: F,
) -> syn::Result<()>
where
    F: FnOnce() -> syn::Result<ScenarioSelector>,
{
    if let Some(existing) = selector {
        return Err(selector_conflict_error(existing, kind, span));
    }
    *selector = Some(build()?);
    Ok(())
}

/// Set the scenario selector to an index, rejecting conflicts with an existing selector.
fn set_selector_index(selector: &mut Option<ScenarioSelector>, i: &LitInt) -> syn::Result<()> {
    set_selector(selector, SelectorKind::Index, i.span(), || {
        Ok(ScenarioSelector::Index {
            value: i.base10_parse()?,
            span: i.span(),
        })
    })
}

/// Set the scenario selector to a name, rejecting conflicts with an existing selector.
fn set_selector_name(selector: &mut Option<ScenarioSelector>, lit: &LitStr) -> syn::Result<()> {
    set_selector(selector, SelectorKind::Name, lit.span(), || {
        Ok(ScenarioSelector::Name {
            value: lit.value(),
            span: lit.span(),
        })
    })
}

/// Documents the internal `SelectorKind` item.
enum SelectorKind {
    /// Represents the internal validation outcome.
    Index,
    /// Represents the internal validation outcome.
    Name,
}

/// Provides the internal `selector_conflict_error` operation.
fn selector_conflict_error(
    existing: &ScenarioSelector,
    new_kind: SelectorKind,
    new_span: Span,
) -> syn::Error {
    match (existing, new_kind) {
        (ScenarioSelector::Index { .. }, SelectorKind::Index) => {
            syn::Error::new(new_span, "duplicate `index` argument")
        }
        (ScenarioSelector::Name { .. }, SelectorKind::Name) => {
            syn::Error::new(new_span, "duplicate `name` argument")
        }
        (ScenarioSelector::Index { span, .. }, SelectorKind::Name) => {
            let mut err = syn::Error::new(
                new_span,
                "`name` cannot be combined with `index`; choose one selector",
            );
            err.combine(syn::Error::new(
                *span,
                "`index` cannot be combined with `name`",
            ));
            err
        }
        (ScenarioSelector::Name { span, .. }, SelectorKind::Index) => {
            let mut err = syn::Error::new(new_span, "`index` cannot be combined with `name`");
            err.combine(syn::Error::new(
                *span,
                "`name` cannot be combined with `index`; choose one selector",
            ));
            err
        }
    }
}

#[cfg(test)]
#[path = "args/tests.rs"]
mod tests;
