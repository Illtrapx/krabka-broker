//! rstest `#[case]` attributes generated from Scenario Outline rows.
//!
//! Every row becomes a case, including rows whose cells are all empty: empty
//! strings are legitimate boundary inputs, and Cucumber runs such rows. Each
//! case uses rstest's named form, `#[case::<name>(..)]`, with the row's name
//! from [`ExampleTable::case_names`], so rstest reports `case_<n>_<name>`.

use proc_macro2::TokenStream as TokenStream2;
use quote::{format_ident, quote};

use super::helpers::cell_to_lit;
use crate::parsing::examples::ExampleTable;

/// Generate one named `#[case]` attribute per Examples row.
///
/// # Examples
///
/// For a table with a `name` column and rows `Alice` and `Bob`:
///
/// ```text
/// #[case::alice("Alice")]
/// #[case::bob("Bob")]
/// ```
pub(crate) fn generate_case_attrs(examples: &ExampleTable) -> Vec<TokenStream2> {
    generate_case_attrs_internal(examples, false)
}

/// Generate named case attributes with a prepended case index for outlines.
///
/// The index is the row's position in `examples.rows`, which is also its
/// position in the substituted step table, so the generated test selects the
/// steps of its own row.
///
/// # Examples
///
/// For an Examples table with rows `["5", "apples"]` and `["10", "oranges"]`:
///
/// ```text
/// #[case::v_5(0usize, "5", "apples")]
/// #[case::v_10(1usize, "10", "oranges")]
/// ```
pub(crate) fn generate_indexed_case_attrs(examples: &ExampleTable) -> Vec<TokenStream2> {
    generate_case_attrs_internal(examples, true)
}

/// Build the case attributes, optionally prepending each row's index.
fn generate_case_attrs_internal(examples: &ExampleTable, prepend_index: bool) -> Vec<TokenStream2> {
    examples
        .rows
        .iter()
        .zip(&examples.case_names)
        .enumerate()
        .map(|(idx, (row, case_name))| {
            let case_ident = format_ident!("{}", case_name);
            let cells = row.iter().map(|value| cell_to_lit(value));
            if prepend_index {
                let idx_lit =
                    syn::LitInt::new(&format!("{idx}usize"), proc_macro2::Span::call_site());
                quote! { #[case::#case_ident( #idx_lit, #(#cells),* )] }
            } else {
                quote! { #[case::#case_ident( #(#cells),* )] }
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    //! Unit tests for outline case attribute generation.

    use super::*;

    fn table(rows: &[&str], names: &[&str]) -> ExampleTable {
        ExampleTable {
            headers: vec!["value".to_owned()],
            rows: rows.iter().map(|&cell| vec![cell.to_owned()]).collect(),
            row_tags: vec![Vec::new(); rows.len()],
            case_names: names.iter().map(|&name| name.to_owned()).collect(),
        }
    }

    fn rendered(attrs: &[TokenStream2]) -> Vec<String> {
        attrs.iter().map(ToString::to_string).collect()
    }

    #[test]
    fn all_empty_rows_become_cases_with_aligned_indexes() {
        let examples = table(&["a", "", "b"], &["a", "row", "b"]);
        assert_eq!(
            rendered(&generate_indexed_case_attrs(&examples)),
            [
                "# [case :: a (0usize , \"a\")]",
                "# [case :: row (1usize , \"\")]",
                "# [case :: b (2usize , \"b\")]",
            ]
        );
    }

    #[test]
    fn unindexed_cases_are_named() {
        let examples = table(&["Alice"], &["alice"]);
        assert_eq!(
            rendered(&generate_case_attrs(&examples)),
            ["# [case :: alice (\"Alice\")]"]
        );
    }
}
