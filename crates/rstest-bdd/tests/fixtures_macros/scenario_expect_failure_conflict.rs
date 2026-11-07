//! Compile-fail fixture: a scenario matching both `ignore_tags` and
//! `expect_failure_tags` has no meaningful outcome and is rejected.

use rstest_bdd_macros::scenario;

#[scenario(
    path = "expect_failure_conflict.feature",
    ignore_tags = "@formulated",
    expect_failure_tags = "@inprogress"
)]
fn conflicting_policies() {}

const _: &str = include_str!("expect_failure_conflict.feature");

fn main() {}
