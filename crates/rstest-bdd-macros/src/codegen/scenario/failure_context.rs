//! Location context appended to step failure messages.
//!
//! The runtime `ExecutionError` names the feature, the scenario, and the step
//! text, but not where the step was written, which rule it belongs to, which
//! outline row was running, or the keyword the author used (`And`, `*`). All of
//! that is known at expansion time, so each step's context is rendered here
//! into a string literal, and the generated step loop appends the failing
//! step's context to the error before panicking.
//!
//! A rendered context reads:
//!
//! ```text
//!   at tests/features/billing.feature:14
//!   rule: Late fees
//!   scenario: Paying a late invoice
//!   example: amount = "150"
//!   step: And the invoice is paid
//! ```
//!
//! The `rule:` and `example:` lines appear only when they apply.

use super::domain::{ExampleHeaders, ExampleRow};
use crate::parsing::{feature::ParsedStep, placeholder::substitute_placeholders};

/// The scenario-level part of every step context.
#[derive(Debug, Clone, Copy)]
pub(crate) struct FailureScope<'a> {
    /// Manifest-relative feature path embedded in the generated test.
    pub(crate) feature_path: &'a str,
    /// Name of the `Rule:` declaring the scenario, if any.
    pub(crate) rule: Option<&'a str>,
    /// Scenario name.
    pub(crate) scenario: &'a str,
}

/// Render the context of every step of a scenario without Examples.
///
/// # Examples
///
/// ```rust,ignore
/// let contexts = scenario_step_contexts(scope, &steps);
/// assert!(contexts[0].starts_with("  at tests/features/x.feature:3"));
/// ```
pub(crate) fn scenario_step_contexts(scope: FailureScope<'_>, steps: &[ParsedStep]) -> Vec<String> {
    steps
        .iter()
        .map(|step| render(scope, step, &step.text, None))
        .collect()
}

/// Render the context of every step for one Examples row, with the row's
/// values substituted into the step text.
pub(crate) fn outline_row_step_contexts(
    scope: FailureScope<'_>,
    steps: &[ParsedStep],
    headers: &ExampleHeaders,
    row: &ExampleRow,
) -> Vec<String> {
    let example = headers
        .as_slice()
        .iter()
        .zip(row.as_slice())
        .map(|(header, value)| format!("{header} = \"{value}\""))
        .collect::<Vec<_>>()
        .join(", ");
    steps
        .iter()
        .map(|step| {
            let text = substitute_placeholders(&step.text, headers.as_slice(), row.as_slice());
            render(scope, step, &text, Some(&example))
        })
        .collect()
}

/// Render one step's context lines.
fn render(scope: FailureScope<'_>, step: &ParsedStep, text: &str, example: Option<&str>) -> String {
    let mut lines = vec![format!("  at {}:{}", scope.feature_path, step.source.line)];
    if let Some(rule) = scope.rule {
        lines.push(format!("  rule: {rule}"));
    }
    lines.push(format!("  scenario: {}", scope.scenario));
    if let Some(example) = example {
        lines.push(format!("  example: {example}"));
    }
    lines.push(format!("  step: {} {text}", step.source.keyword));
    lines.join("\n")
}

#[cfg(test)]
mod tests {
    //! Unit tests for step failure context rendering.

    use super::*;
    use crate::parsing::feature::StepSource;

    fn step(keyword: &str, text: &str, line: usize) -> ParsedStep {
        ParsedStep {
            keyword: crate::StepKeyword::Given,
            source: StepSource {
                keyword: keyword.to_owned(),
                line,
            },
            text: text.to_owned(),
            docstring: None,
            table: None,
            #[cfg(feature = "compile-time-validation")]
            span: proc_macro2::Span::call_site(),
        }
    }

    const SCOPE: FailureScope<'static> = FailureScope {
        feature_path: "tests/features/billing.feature",
        rule: None,
        scenario: "Paying",
    };

    #[test]
    fn renders_scenario_steps_without_optional_lines() {
        let contexts = scenario_step_contexts(SCOPE, &[step("*", "an invoice", 4)]);
        assert_eq!(
            contexts,
            [concat!(
                "  at tests/features/billing.feature:4\n",
                "  scenario: Paying\n",
                "  step: * an invoice",
            )]
        );
    }

    #[test]
    fn renders_rule_and_substituted_example_row() {
        let scope = FailureScope {
            rule: Some("Late fees"),
            ..SCOPE
        };
        let headers = ExampleHeaders::new(vec!["amount".to_owned(), "note".to_owned()]);
        let row = ExampleRow::new(vec!["150".to_owned(), String::new()]);
        let contexts =
            outline_row_step_contexts(scope, &[step("And", "<amount> is paid", 9)], &headers, &row);
        assert_eq!(
            contexts,
            [concat!(
                "  at tests/features/billing.feature:9\n",
                "  rule: Late fees\n",
                "  scenario: Paying\n",
                "  example: amount = \"150\", note = \"\"\n",
                "  step: And 150 is paid",
            )]
        );
    }
}
