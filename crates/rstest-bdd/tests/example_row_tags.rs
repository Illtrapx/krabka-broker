//! Behavioural test for per-row Examples tags reported at run time.
//!
//! The harness records the scenario tags it is handed on the running
//! thread, and a step compares them with the row's expected tags.

use std::cell::RefCell;

use rstest_bdd_harness::{HarnessAdapter, HarnessError, StdScenarioRunRequest};
use rstest_bdd_macros::{scenario, then};

thread_local! {
    static REPORTED_TAGS: RefCell<Vec<String>> = const { RefCell::new(Vec::new()) };
}

/// Records the scenario tags of each run before executing it.
#[derive(Default)]
struct TagRecordingHarness;

impl HarnessAdapter for TagRecordingHarness {
    type Context = ();

    fn run<T>(&self, request: StdScenarioRunRequest<'_, T>) -> Result<T, HarnessError> {
        let tags = request.metadata().tags().to_vec();
        REPORTED_TAGS.with(|reported| *reported.borrow_mut() = tags);
        Ok(request.run_without_context())
    }
}

#[then("the reported tags include {tag:string} but not {other:string}")]
fn reported_tags_include(tag: String, other: String) {
    let reported = REPORTED_TAGS.with(|reported| reported.borrow().clone());
    assert!(
        reported.contains(&"@outline_feature".to_owned()),
        "{reported:?}"
    );
    assert!(reported.contains(&tag), "{reported:?} should include {tag}");
    assert!(
        !reported.contains(&other),
        "{reported:?} should exclude {other}"
    );
}

#[scenario(
    path = "tests/features/krabka/example_row_tags.feature",
    harness = TagRecordingHarness
)]
fn rows_report_their_own_tags(#[case] tag: String, #[case] other: String) { let _ = (tag, other); }
