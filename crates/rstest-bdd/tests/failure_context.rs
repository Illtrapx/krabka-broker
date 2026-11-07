//! Behavioural tests for the source context appended to step failures.
//!
//! A harness catches each scenario's panic and checks that the message ends
//! with the expected context, then panics with a short marker the test
//! expects. Undefined steps fail through the same step-loop error branch,
//! but strict compile-time validation turns them into compile errors, so
//! these scenarios use steps that are defined and panic.

use std::panic::{AssertUnwindSafe, catch_unwind};

use rstest_bdd_harness::{HarnessAdapter, HarnessError, StdScenarioRunRequest};
use rstest_bdd_macros::{given, scenario};

#[given("the diagnostics fixture is ready")]
fn diagnostics_ready() {}

#[given("the bullet step fails")]
fn bullet_step_fails() {
    panic!("bullet step failed");
}

#[given("the value {value} is rejected")]
fn value_rejected(value: String) {
    panic!("value {value} rejected");
}

/// Context each scenario's failure message must end with.
fn expected_context(scenario: &str) -> &'static str {
    match scenario {
        "Failing bullet step" => concat!(
            "\n  at tests/features/krabka/failure_context.feature:6\n",
            "  scenario: Failing bullet step\n",
            "  step: * the bullet step fails",
        ),
        "Failing row step" => concat!(
            "\n  at tests/features/krabka/failure_context.feature:11\n",
            "  rule: Outline failures\n",
            "  scenario: Failing row step\n",
            "  example: value = \"42\"\n",
            "  step: And the value 42 is rejected",
        ),
        other => panic!("unexpected scenario {other}"),
    }
}

/// Checks the failure message of a scenario that must fail.
#[derive(Default)]
struct FailureContextHarness;

impl HarnessAdapter for FailureContextHarness {
    type Context = ();

    fn run<T>(&self, request: StdScenarioRunRequest<'_, T>) -> Result<T, HarnessError> {
        let scenario = request.metadata().scenario_name().to_owned();
        let Err(payload) = catch_unwind(AssertUnwindSafe(|| request.run_without_context())) else {
            panic!("scenario `{scenario}` should fail");
        };
        let message = payload
            .downcast_ref::<String>()
            .map_or("<non-string panic>", String::as_str);
        let expected = expected_context(&scenario);
        assert!(
            message.ends_with(expected),
            "failure message should end with {expected:?}: {message:?}"
        );
        panic!("failure context verified");
    }
}

#[scenario(
    path = "tests/features/krabka/failure_context.feature",
    name = "Failing bullet step",
    harness = FailureContextHarness
)]
#[should_panic(expected = "failure context verified")]
fn failing_bullet_step_reports_its_source() {}

#[scenario(
    path = "tests/features/krabka/failure_context.feature",
    name = "Failing row step",
    harness = FailureContextHarness
)]
#[should_panic(expected = "failure context verified")]
fn failing_outline_step_reports_rule_and_row(#[case] value: String) { let _ = value; }
