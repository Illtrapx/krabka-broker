//! `ignore_tags`: generate matching scenarios as ignored tests.
//!
//! A `tags = "..."` filter drops non-matching scenarios entirely. Some
//! scenarios must instead stay compiled and runnable on demand while being
//! excluded from the default run, for example krabka's lifecycle tags
//! `@formulated` and `@inprogress`. `ignore_tags = "<expression>"` marks a
//! matching scenario, or each matching Scenario Outline row, with
//! `#[ignore = "tagged <tags>"]`, so `cargo test -- --ignored` still runs it.
//!
//! Matching uses the same inherited tags as `tags` filtering: feature, rule,
//! scenario, and (for outline rows) Examples-block tags.

use proc_macro2::TokenStream as TokenStream2;
use quote::quote;

use crate::parsing::tags::TagExpression;

/// A parsed `ignore_tags` expression.
#[derive(Debug, Clone)]
pub(crate) struct IgnoreTags {
    /// The parsed expression.
    expr: TagExpression,
    /// The expression as written, used when no mentioned tag is present.
    raw: String,
}

impl IgnoreTags {
    /// Parse an `ignore_tags` literal, reporting syntax errors at its span.
    ///
    /// # Examples
    ///
    /// ```rust,ignore
    /// let lit: syn::LitStr = syn::parse_quote!("@formulated or @inprogress");
    /// let ignore = IgnoreTags::parse(&lit)?;
    /// assert!(ignore.attribute_for(&["@formulated".into()]).is_some());
    /// ```
    pub(crate) fn parse(lit: &syn::LitStr) -> syn::Result<Self> {
        let raw = lit.value();
        TagExpression::parse(&raw)
            .map(|expr| Self { expr, raw })
            .map_err(|err| syn::Error::new(lit.span(), err.to_string()))
    }

    /// Return the `#[ignore]` attribute for a test carrying `tags`, if the
    /// expression matches them.
    pub(crate) fn attribute_for(&self, tags: &[String]) -> Option<TokenStream2> {
        self.reason_for(tags)
            .map(|reason| quote! { #[ignore = #reason] })
    }

    /// Explain why a test carrying `tags` is ignored, if it is.
    ///
    /// The reason names the matching tags the expression mentions, for
    /// example `tagged @formulated`. An expression matched only through
    /// negation mentions no present tag, so the expression itself is quoted.
    fn reason_for(&self, tags: &[String]) -> Option<String> {
        if !self.expr.evaluate(tags.iter().map(String::as_str)) {
            return None;
        }
        let present: Vec<&str> = self
            .expr
            .referenced_tags()
            .into_iter()
            .filter(|tag| tags.iter().any(|candidate| candidate == tag))
            .collect();
        Some(if present.is_empty() {
            format!("matches ignore_tags `{}`", self.raw)
        } else {
            format!("tagged {}", present.join(" "))
        })
    }
}

/// Return the `#[ignore]` attribute for `tags` under an optional policy.
pub(crate) fn ignore_attribute(ignore: Option<&IgnoreTags>, tags: &[String]) -> TokenStream2 {
    ignore
        .and_then(|policy| policy.attribute_for(tags))
        .unwrap_or_default()
}

#[cfg(test)]
mod tests {
    //! Unit tests for `ignore_tags` matching and reasons.

    use rstest::rstest;

    use super::*;

    fn policy(expr: &str) -> IgnoreTags {
        IgnoreTags::parse(&syn::LitStr::new(expr, proc_macro2::Span::call_site()))
            .expect("expression should parse")
    }

    fn tags(list: &[&str]) -> Vec<String> { list.iter().map(|&tag| tag.to_owned()).collect() }

    #[rstest]
    #[case::single("@formulated or @inprogress", &["@feature", "@formulated"], Some("tagged @formulated"))]
    #[case::both("@formulated or @inprogress", &["@inprogress", "@formulated"], Some("tagged @formulated @inprogress"))]
    #[case::unmatched("@formulated", &["@feature"], None)]
    #[case::negation("not @ready", &["@feature"], Some("matches ignore_tags `not @ready`"))]
    fn explains_matches(
        #[case] expr: &str,
        #[case] scenario_tags: &[&str],
        #[case] expected: Option<&str>,
    ) {
        assert_eq!(
            policy(expr).reason_for(&tags(scenario_tags)).as_deref(),
            expected
        );
    }

    #[test]
    fn emits_ignore_attribute_with_reason() {
        let attribute = ignore_attribute(Some(&policy("@wip")), &tags(&["@wip"]));
        assert_eq!(attribute.to_string(), "# [ignore = \"tagged @wip\"]");
        assert!(ignore_attribute(None, &tags(&["@wip"])).is_empty());
    }

    #[test]
    fn reports_syntax_errors() {
        let lit = syn::LitStr::new("@a and", proc_macro2::Span::call_site());
        assert!(IgnoreTags::parse(&lit).is_err());
    }
}
