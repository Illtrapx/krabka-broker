//! Behavioural tests for scenarios declared under Gherkin `Rule:` blocks.
//!
//! Each scenario records its steps in a journal fixture so the tests prove
//! the rule scenarios actually execute, in the order feature background,
//! rule background, scenario steps.

use std::cell::RefCell;

use rstest::fixture;
use rstest_bdd_macros::{given, scenario, scenarios, then, when};

/// Ordered record of the steps a scenario executed.
#[derive(Default)]
struct Journal(RefCell<Vec<String>>);

impl Journal {
    fn push(&self, entry: &str) { self.0.borrow_mut().push(entry.to_owned()); }

    fn joined(&self) -> String { self.0.borrow().join(", ") }
}

#[rstest_bdd_test_macros::allow_fixture_expansion_lints]
#[fixture]
fn journal() -> Journal { Journal::default() }

#[given("the feature background is journalled")]
fn feature_background(journal: &Journal) { journal.push("feature"); }

#[given("the rule background is journalled")]
fn rule_background(journal: &Journal) { journal.push("rule"); }

#[when("the scenario step is journalled")]
fn scenario_step(journal: &Journal) { journal.push("scenario"); }

#[when("the value {value} is journalled")]
fn value_step(journal: &Journal, value: String) { journal.push(&value); }

#[then("the journal reads {expected:string}")]
fn journal_reads(journal: &Journal, expected: String) {
    assert_eq!(journal.joined(), expected);
}

#[then("the rule scenario panics")]
fn rule_scenario_panics() {
    panic!("rule scenario executed");
}

#[then("the test is named {expected:string}")]
fn test_is_named(expected: String) {
    // libtest names each test thread after the test path; a single-threaded
    // runner may execute on `main`, where there is nothing to compare.
    let current = std::thread::current();
    if let Some(name) = current.name().filter(|name| name.contains("::")) {
        assert!(
            name.ends_with(&format!("::{expected}")),
            "test `{name}` should be named `{expected}`"
        );
    }
}

#[scenario(
    path = "tests/features/krabka/rules/rule_blocks.feature",
    name = "Rule scenario follows both backgrounds"
)]
fn rule_scenario_selected_by_name(journal: Journal) {
    assert_eq!(journal.joined(), "feature, rule, scenario, scenario");
}

#[scenario(path = "tests/features/krabka/rules/rule_blocks.feature", index = 1)]
fn rule_scenario_selected_by_index(journal: Journal) {
    assert_eq!(journal.joined(), "feature, rule, scenario, scenario");
}

#[scenario(path = "tests/features/krabka/rules/rule_blocks.feature", index = 0)]
fn scenario_outside_rule_keeps_its_index(journal: Journal) {
    assert_eq!(journal.joined(), "feature, scenario");
}

#[scenario(
    path = "tests/features/krabka/rules/rule_blocks.feature",
    name = "Rule scenario reaches its failing step"
)]
#[should_panic(expected = "rule scenario executed")]
fn rule_scenario_failure_propagates(journal: Journal) { let _ = journal; }

#[scenario(
    path = "tests/features/krabka/rules/rule_blocks.feature",
    name = "Rule outline substitutes placeholders"
)]
fn rule_outline_runs_each_row(journal: Journal, #[case] value: String) {
    assert_eq!(journal.joined(), format!("feature, rule, {value}"));
}

// Only the rule tag selects these scenarios, so the filter proves rule tags
// are inherited; the feature tag alone would also match the outside scenario.
scenarios!(
    "tests/features/krabka/rules",
    tags = "@ordering and @rule_feature",
    fixtures = [journal: Journal]
);

scenarios!("tests/features/krabka/rules_auto");
