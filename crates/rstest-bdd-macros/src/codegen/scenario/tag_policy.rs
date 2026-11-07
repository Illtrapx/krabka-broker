//! Tag-expression policies that change how matching tests are generated.
//!
//! A `tags = "..."` filter drops non-matching scenarios entirely. Two further
//! arguments keep matching scenarios compiled but change their outcome:
//!
//! - `ignore_tags = "<expression>"` marks a matching scenario, or each matching Scenario Outline
//!   row, with `#[ignore = "tagged <tags>"]`, so the default run skips it and `cargo test --
//!   --ignored` still runs it (krabka's `@formulated`).
//! - `expect_failure_tags = "<expression>"` runs a matching scenario or row as an expected failure:
//!   the test passes while a step fails, and fails with "scenario tagged <tags> now passes: remove
//!   the tag" once every step passes (krabka's `@inprogress`). This is the BDD "see it fail first,
//!   then make it pass" loop.
//!
//! Matching uses the same inherited tags as `tags` filtering: feature, rule,
//! scenario, and (for outline rows) Examples-block tags. A test matched by both
//! policies has no meaningful outcome, so that is a compile error.

use proc_macro2::TokenStream as TokenStream2;
use quote::quote;

use crate::parsing::tags::TagExpression;

/// A parsed tag-expression policy argument.
#[derive(Debug, Clone)]
pub(crate) struct TagPolicy {
    /// The parsed expression.
    expr: TagExpression,
    /// The expression as written, used when no mentioned tag is present.
    raw: String,
    /// The macro argument that supplied the expression, for messages.
    argument: &'static str,
}

impl TagPolicy {
    /// Parse a policy literal, reporting syntax errors at its span.
    ///
    /// # Examples
    ///
    /// ```rust,ignore
    /// let lit: syn::LitStr = syn::parse_quote!("@formulated or @inprogress");
    /// let ignore = TagPolicy::parse(&lit, "ignore_tags")?;
    /// assert_eq!(ignore.reason_for(&["@formulated".into()]).as_deref(), Some("tagged @formulated"));
    /// ```
    pub(crate) fn parse(lit: &syn::LitStr, argument: &'static str) -> syn::Result<Self> {
        let raw = lit.value();
        TagExpression::parse(&raw)
            .map(|expr| Self {
                expr,
                raw,
                argument,
            })
            .map_err(|err| syn::Error::new(lit.span(), err.to_string()))
    }

    /// Parse an optional policy literal.
    pub(crate) fn parse_optional(
        lit: Option<&syn::LitStr>,
        argument: &'static str,
    ) -> syn::Result<Option<Self>> {
        lit.map(|lit| Self::parse(lit, argument)).transpose()
    }

    /// Explain why a test carrying `tags` falls under the policy, if it does.
    ///
    /// The reason names the matching tags the expression mentions, for
    /// example `tagged @formulated`. An expression matched only through
    /// negation mentions no present tag, so the expression itself is quoted.
    pub(crate) fn reason_for(&self, tags: &[String]) -> Option<String> {
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
            format!("matching {} `{}`", self.argument, self.raw)
        } else {
            format!("tagged {}", present.join(" "))
        })
    }
}

/// Return the `#[ignore]` attribute for `tags` under an optional policy.
pub(crate) fn ignore_attribute(ignore: Option<&TagPolicy>, tags: &[String]) -> TokenStream2 {
    ignore
        .and_then(|policy| policy.reason_for(tags))
        .map(|reason| quote! { #[ignore = #reason] })
        .unwrap_or_default()
}

/// Return the expected-failure reason for `tags` under an optional policy.
pub(crate) fn expected_failure_reason(
    expect_failure: Option<&TagPolicy>,
    tags: &[String],
) -> Option<String> {
    expect_failure.and_then(|policy| policy.reason_for(tags))
}

/// Report a compile error when one tag set matches both policies.
pub(crate) fn reject_conflicting_policies<'t>(
    ignore: Option<&TagPolicy>,
    expect_failure: Option<&TagPolicy>,
    scenario: &str,
    tag_sets: impl IntoIterator<Item = &'t [String]>,
) -> Option<TokenStream2> {
    let (ignore, expect_failure) = ignore.zip(expect_failure)?;
    let conflicting = tag_sets.into_iter().find(|tags| {
        ignore.reason_for(tags).is_some() && expect_failure.reason_for(tags).is_some()
    })?;
    let message = format!(
        "scenario \"{scenario}\" matches both `ignore_tags` (`{}`) and `expect_failure_tags` \
         (`{}`) through tags [{}]; a test cannot be both ignored and expected to fail",
        ignore.raw,
        expect_failure.raw,
        conflicting.join(", "),
    );
    Some(syn::Error::new(proc_macro2::Span::call_site(), message).into_compile_error())
}

#[cfg(test)]
mod tests {
    //! Unit tests for tag policy matching, reasons, and conflicts.

    use rstest::rstest;

    use super::*;

    fn policy(expr: &str, argument: &'static str) -> TagPolicy {
        TagPolicy::parse(
            &syn::LitStr::new(expr, proc_macro2::Span::call_site()),
            argument,
        )
        .expect("expression should parse")
    }

    fn tags(list: &[&str]) -> Vec<String> { list.iter().map(|&tag| tag.to_owned()).collect() }

    #[rstest]
    #[case::single("@formulated or @inprogress", &["@feature", "@formulated"], Some("tagged @formulated"))]
    #[case::both("@formulated or @inprogress", &["@inprogress", "@formulated"], Some("tagged @formulated @inprogress"))]
    #[case::unmatched("@formulated", &["@feature"], None)]
    #[case::negation("not @ready", &["@feature"], Some("matching ignore_tags `not @ready`"))]
    fn explains_matches(
        #[case] expr: &str,
        #[case] scenario_tags: &[&str],
        #[case] expected: Option<&str>,
    ) {
        assert_eq!(
            policy(expr, "ignore_tags")
                .reason_for(&tags(scenario_tags))
                .as_deref(),
            expected
        );
    }

    #[test]
    fn emits_ignore_attribute_with_reason() {
        let attribute = ignore_attribute(Some(&policy("@wip", "ignore_tags")), &tags(&["@wip"]));
        assert_eq!(attribute.to_string(), "# [ignore = \"tagged @wip\"]");
        assert!(ignore_attribute(None, &tags(&["@wip"])).is_empty());
    }

    #[test]
    fn reports_syntax_errors() {
        let lit = syn::LitStr::new("@a and", proc_macro2::Span::call_site());
        assert!(TagPolicy::parse(&lit, "ignore_tags").is_err());
    }

    #[test]
    fn rejects_tags_matching_both_policies() {
        let ignore = policy("@formulated", "ignore_tags");
        let expect = policy("@inprogress or @formulated", "expect_failure_tags");
        let clean = tags(&["@inprogress"]);
        let both = tags(&["@formulated"]);
        assert!(
            reject_conflicting_policies(Some(&ignore), Some(&expect), "s", [clean.as_slice()])
                .is_none()
        );
        let error = reject_conflicting_policies(
            Some(&ignore),
            Some(&expect),
            "s",
            [clean.as_slice(), both.as_slice()],
        )
        .expect("conflict should be reported")
        .to_string();
        assert!(error.contains("matches both `ignore_tags`"), "{error}");
        assert!(reject_conflicting_policies(None, Some(&expect), "s", [both.as_slice()]).is_none());
    }
}
