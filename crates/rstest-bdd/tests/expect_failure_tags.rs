//! Behavioural tests for the `expect_failure_tags` argument.
//!
//! The test binary inspects itself, as in `ignore_tags.rs`: expected-failure
//! tests must pass in the default run, and a scenario whose steps all pass
//! must fail with an explicit "now passes" message.

use rstest_bdd_macros::{given, scenario, scenarios, then};

#[given("the behaviour is started")]
fn behaviour_started() {}

#[then("the behaviour is finished")]
fn behaviour_finished() {}

#[then("the behaviour is finished but it is not")]
fn behaviour_unfinished() {
    panic!("behaviour is not finished yet");
}

#[then("the row is {state}")]
fn row_is(state: String) {
    assert_eq!(state, "finished", "row is not finished yet");
}

scenarios!(
    "tests/features/krabka/expect_failure",
    ignore_tags = "@formulated",
    expect_failure_tags = "@inprogress"
);

#[scenario(
    path = "tests/features/krabka/expect_failure_passing.feature",
    expect_failure_tags = "@inprogress"
)]
#[should_panic(expected = "scenario tagged @inprogress now passes: remove the tag")]
fn passing_expected_failure_asks_for_the_tag_to_go() {}

#[scenario(
    path = "tests/features/krabka/expect_failure/lifecycle.feature",
    name = "Unfinished behaviour fails as expected",
    expect_failure_tags = "@inprogress"
)]
fn scenario_attribute_honours_expect_failure_tags() {}

/// Every generated test that must pass in the default run.
const EXPECTED_PASSING: &[&str] = &[
    "expect_failure_scenarios::lifecycle_finished_behaviour_passes_normally",
    "expect_failure_scenarios::lifecycle_unfinished_behaviour_fails_as_expected",
    "expect_failure_scenarios::lifecycle_unfinished_rule_rule_scenario_inherits_the_expectation",
    "expect_failure_scenarios::lifecycle_mixed_rows_outline_rows_expect_failure_per_block::case_1_done_finished",
    "expect_failure_scenarios::lifecycle_mixed_rows_outline_rows_expect_failure_per_block::case_2_pending_unfinished",
    "scenario_attribute_honours_expect_failure_tags",
];

#[test]
fn expected_failures_pass_in_the_default_run() {
    let exe = std::env::current_exe().expect("test binary path should resolve");
    for name in EXPECTED_PASSING {
        let output = std::process::Command::new(&exe)
            .args(["--exact", name])
            .output()
            .expect("test binary should run");
        let stdout = String::from_utf8_lossy(&output.stdout);
        assert!(
            output.status.success() && stdout.contains("1 passed"),
            "{name} should pass: {stdout}"
        );
    }
}
