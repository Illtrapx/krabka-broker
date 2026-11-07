//! Behavioural test for descriptive Scenario Outline case names.

use rstest_bdd_macros::{scenario, then};

#[then("the running case is named {case:string}")]
fn running_case_is_named(case: String) {
    // libtest names each test thread after the test path; a single-threaded
    // runner may execute on `main`, where there is nothing to compare.
    let current = std::thread::current();
    if let Some(name) = current.name().filter(|name| name.contains("::")) {
        assert!(
            name.ends_with(&format!("::{case}")),
            "test `{name}` should be named `{case}`"
        );
    }
}

#[scenario(path = "tests/features/krabka/outline_case_names.feature")]
fn outline_cases_are_named(#[case] label: String, #[case] case: String) { let _ = (label, case); }
