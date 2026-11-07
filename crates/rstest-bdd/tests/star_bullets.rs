//! Behavioural test for `*` bullet steps.
//!
//! Each step is defined under exactly one keyword, so a bullet resolving to
//! the wrong keyword fails step lookup. The journal proves every step ran.

use std::cell::RefCell;

use rstest::fixture;
use rstest_bdd_macros::{given, scenario, then, when};

#[rstest_bdd_test_macros::allow_fixture_expansion_lints]
#[fixture]
fn journal() -> RefCell<Vec<&'static str>> { RefCell::default() }

#[given("the bullet journal is open")]
fn journal_open(journal: &RefCell<Vec<&'static str>>) { journal.borrow_mut().push("open"); }

#[given("a precondition is journalled")]
fn precondition(journal: &RefCell<Vec<&'static str>>) { journal.borrow_mut().push("given"); }

#[when("an action is journalled")]
fn action(journal: &RefCell<Vec<&'static str>>) { journal.borrow_mut().push("when"); }

#[when("another action is journalled")]
fn another_action(journal: &RefCell<Vec<&'static str>>) { journal.borrow_mut().push("when*"); }

#[then("an outcome is journalled")]
fn outcome(journal: &RefCell<Vec<&'static str>>) { journal.borrow_mut().push("then"); }

#[then("another outcome is journalled")]
fn another_outcome(journal: &RefCell<Vec<&'static str>>) { journal.borrow_mut().push("then*"); }

#[scenario(path = "tests/features/krabka/star_bullets.feature")]
fn bullets_inherit_the_preceding_keyword(journal: RefCell<Vec<&'static str>>) {
    assert_eq!(
        journal.into_inner(),
        ["open", "given", "when", "when*", "then", "then*"]
    );
}
