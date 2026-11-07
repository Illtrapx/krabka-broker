//! rstest `#[case]` attributes generated from Scenario Outline rows.
//!
//! Every row becomes a case, including rows whose cells are all empty: empty
//! strings are legitimate boundary inputs, and Cucumber runs such rows. Each
//! case uses rstest's named form, `#[case::<name>(..)]`, with the row's name
//! from [`ExampleTable::case_names`], so rstest reports `case_<n>_<name>`.

use proc_macro2::TokenStream as TokenStream2;
use quote::{format_ident, quote};

use super::{
    helpers::cell_to_lit,
    tag_policy::{TagPolicy, ignore_attribute},
};
use crate::parsing::examples::ExampleTable;

/// Generate one named case attribute per row, prepending the row's index.
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
///
/// rstest applies attributes written before a `#[case]` to that case only, so
/// a row matching the `ignore_tags` policy gets its `#[ignore]` immediately
/// before its own case attribute.
pub(crate) fn generate_indexed_case_attrs(
    examples: &ExampleTable,
    ignore: Option<&TagPolicy>,
) -> Vec<TokenStream2> {
    examples
        .rows
        .iter()
        .zip(&examples.case_names)
        .zip(&examples.row_tags)
        .enumerate()
        .map(|(idx, ((row, case_name), row_tags))| {
            let ignore = ignore_attribute(ignore, row_tags);
            let case_ident = format_ident!("{}", case_name);
            let idx_lit = syn::LitInt::new(&format!("{idx}usize"), proc_macro2::Span::call_site());
            let cells = row.iter().map(|value| cell_to_lit(value));
            quote! { #ignore #[case::#case_ident( #idx_lit, #(#cells),* )] }
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
            rendered(&generate_indexed_case_attrs(&examples, None)),
            [
                "# [case :: a (0usize , \"a\")]",
                "# [case :: row (1usize , \"\")]",
                "# [case :: b (2usize , \"b\")]",
            ]
        );
    }

    #[test]
    fn ignored_rows_get_their_own_ignore_attribute() {
        let mut examples = table(&["a", "b"], &["a", "b"]);
        examples.row_tags = vec![vec!["@ready".to_owned()], vec!["@formulated".to_owned()]];
        let lit = syn::LitStr::new("@formulated", proc_macro2::Span::call_site());
        let ignore = TagPolicy::parse(&lit, "ignore_tags").expect("expression should parse");
        assert_eq!(
            rendered(&generate_indexed_case_attrs(&examples, Some(&ignore))),
            [
                "# [case :: a (0usize , \"a\")]",
                "# [ignore = \"tagged @formulated\"] # [case :: b (1usize , \"b\")]",
            ]
        );
    }
}
