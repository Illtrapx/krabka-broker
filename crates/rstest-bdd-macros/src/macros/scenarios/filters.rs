//! Compile-time tag filtering and empty-result diagnostics for `scenarios!`.

use proc_macro::TokenStream;
use proc_macro2::{Span, TokenStream as TokenStream2};

use crate::{parsing::tags::TagExpression, utils::errors::error_to_tokens};

/// Internal data used by the macros implementation.
pub(super) struct TagFilter {
    /// Stores the internal `expr` value.
    pub(super) expr: TagExpression,
    /// Stores the internal `span` value.
    pub(super) span: Span,
    /// Stores the internal `raw` value.
    pub(super) raw: String,
}

/// Provides the internal `parse_tag_filter` operation.
pub(super) fn parse_tag_filter(
    tag_lit: Option<syn::LitStr>,
) -> Result<Option<TagFilter>, TokenStream> {
    tag_lit.map_or_else(
        || Ok(None),
        |lit| match TagExpression::parse(&lit.value()) {
            Ok(expr) => Ok(Some(TagFilter {
                expr,
                span: lit.span(),
                raw: lit.value(),
            })),
            Err(err) => {
                let syn_err = syn::Error::new(lit.span(), err.to_string());
                Err(error_to_tokens(&syn_err).into())
            }
        },
    )
}

/// Report a compile error when an expansion generated no tests at all.
///
/// An empty result almost always means a wrong path or a feature whose
/// scenarios the macros cannot see, so it fails loudly rather than emitting an
/// empty module. Scenarios declared under a `Rule:` count, because rule
/// scenarios are flattened into the feature before tests are generated.
pub(super) fn check_empty_results(
    tests: &[TokenStream2],
    errors: &mut Vec<TokenStream2>,
    tag_filter: Option<&TagFilter>,
    dir_lit: &syn::LitStr,
) {
    let is_nothing_emitted = tests.is_empty() && errors.is_empty();
    if !is_nothing_emitted {
        return;
    }
    let err = tag_filter.map_or_else(
        || {
            syn::Error::new(
                dir_lit.span(),
                format!("no scenarios found in `{}`", dir_lit.value()),
            )
        },
        |filter| {
            syn::Error::new(
                filter.span,
                format!("no scenarios matched tag expression `{}`", filter.raw),
            )
        },
    );
    errors.push(error_to_tokens(&err));
}
