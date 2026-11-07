//! Behavioural test for binding step placeholders by name.
//!
//! The parameters are declared in a different order from the placeholders,
//! with distinct types, so positional binding would either swap the values
//! or fail to parse them.

use std::cell::RefCell;

use rstest::fixture;
use rstest_bdd_macros::{given, scenario, then, when};

#[rstest_bdd_test_macros::allow_fixture_expansion_lints]
#[fixture]
fn journal() -> RefCell<Vec<String>> { RefCell::default() }

#[given("the order {first:string} then {second:u32} then {third}")]
fn reordered(third: String, journal: &RefCell<Vec<String>>, second: u32, first: String) {
    journal
        .borrow_mut()
        .push(format!("{first} {second} {third}"));
}

#[when("the renamed order {label:string} then {count:u32} is recorded")]
fn renamed(
    #[from(count)] amount: u32,
    #[from(label)] name: String,
    journal: &RefCell<Vec<String>>,
) {
    journal.borrow_mut().push(format!("{name} {amount}"));
}

#[then("the journal reads {expected:string}")]
fn journal_reads(expected: String, journal: &RefCell<Vec<String>>) {
    assert_eq!(journal.borrow().join(", "), expected);
}

#[scenario(path = "tests/features/krabka/named_placeholders.feature")]
fn reordered_parameters_receive_their_own_values(journal: RefCell<Vec<String>>) {
    assert_eq!(journal.into_inner(), ["alpha 2 gamma", "delta 5"]);
}
