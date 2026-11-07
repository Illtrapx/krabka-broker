//! Behavioural test for placeholders that name no Examples column.

use std::cell::RefCell;

use rstest::fixture;
use rstest_bdd_macros::{given, scenario};

#[rstest_bdd_test_macros::allow_fixture_expansion_lints]
#[fixture]
fn journal() -> RefCell<Vec<String>> { RefCell::default() }

#[given("the text {text:string} is journalled")]
fn text_journalled(journal: &RefCell<Vec<String>>, text: String) {
    journal.borrow_mut().push(text);
}

#[given("the docstring is journalled")]
fn docstring_journalled(journal: &RefCell<Vec<String>>, docstring: String) {
    journal.borrow_mut().push(docstring.trim().to_owned());
}

#[given("the table is journalled")]
fn table_journalled(journal: &RefCell<Vec<String>>, datatable: Vec<Vec<String>>) {
    let cells: Vec<String> = datatable.into_iter().flatten().collect();
    journal.borrow_mut().push(cells.join(" | "));
}

#[scenario(path = "tests/features/krabka/unknown_placeholders.feature")]
fn unknown_placeholders_stay_verbatim(journal: RefCell<Vec<String>>, #[case] known: String) {
    let _ = known;
    assert_eq!(
        journal.into_inner(),
        [
            "value and <unknown>",
            "value keeps <unknown>",
            "value | <unknown>",
        ]
    );
}
