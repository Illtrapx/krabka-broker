//! Behavioural tests for the `ignore_tags` argument.
//!
//! The test binary inspects itself: it lists its ignored tests, checks the
//! reason libtest prints for each, and runs each with `--ignored` to prove it
//! is still generated and passes on demand.

use std::{collections::BTreeSet, process::Command};

use rstest_bdd_macros::{scenario, scenarios, then};

#[then("the lifecycle step passes")]
fn lifecycle_step_passes() {}

#[then("the lifecycle step passes for {state}")]
fn lifecycle_step_passes_for(state: String) {
    assert!(!state.is_empty());
}

scenarios!(
    "tests/features/krabka/ignore_tags",
    ignore_tags = "@formulated or @inprogress or @stage:draft"
);

#[scenario(
    path = "tests/features/krabka/ignore_tags/lifecycle.feature",
    name = "Formulated scenario is ignored",
    ignore_tags = "@formulated"
)]
fn scenario_attribute_honours_ignore_tags() {}

/// Ignored tests and the reason each should report.
const EXPECTED_IGNORED: &[(&str, &str)] = &[
    (
        "ignore_tags_scenarios::drafts_draft_scenario_is_ignored",
        "tagged @stage:draft",
    ),
    (
        "ignore_tags_scenarios::lifecycle_formulated_scenario_is_ignored",
        "tagged @formulated",
    ),
    (
        "ignore_tags_scenarios::lifecycle_mixed_rows_outline_rows_are_ignored_per_block::case_2_planned_planned",
        "tagged @formulated",
    ),
    (
        "ignore_tags_scenarios::lifecycle_work_in_progress_rule_scenario_inherits_the_ignore",
        "tagged @inprogress",
    ),
    ("scenario_attribute_honours_ignore_tags", "tagged @formulated"),
];

/// Run this test binary with `args`, returning its standard output.
///
/// # Errors
///
/// Returns an error when the binary cannot be located or started.
fn run_self(args: &[&str]) -> std::io::Result<String> {
    let output = Command::new(std::env::current_exe()?).args(args).output()?;
    assert!(
        output.status.success(),
        "`{args:?}` failed: {}{}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    Ok(String::from_utf8_lossy(&output.stdout).into_owned())
}

#[test]
fn exactly_the_matching_tests_are_ignored() {
    let listed: BTreeSet<String> = run_self(&["--ignored", "--list"])
        .expect("test binary should list its tests")
        .lines()
        .filter_map(|line| line.strip_suffix(": test"))
        .map(str::to_owned)
        .collect();
    let expected: BTreeSet<String> = EXPECTED_IGNORED
        .iter()
        .map(|(name, _)| (*name).to_owned())
        .collect();
    assert_eq!(listed, expected);
}

#[test]
fn ignored_tests_report_the_matching_tags() {
    for (name, reason) in EXPECTED_IGNORED {
        let stdout = run_self(&["--exact", name]).expect("test binary should run");
        assert!(
            stdout.contains(&format!("{name} ... ignored, {reason}")),
            "{name} should be ignored with reason `{reason}`: {stdout}"
        );
    }
}

#[test]
fn ignored_tests_still_run_on_demand() {
    for (name, _) in EXPECTED_IGNORED {
        let stdout = run_self(&["--ignored", "--exact", name]).expect("test binary should run");
        assert!(
            stdout.contains("1 passed"),
            "{name} should pass when run: {stdout}"
        );
    }
}
