//! Descriptive rstest case names for Scenario Outline rows.
//!
//! Upstream emitted anonymous `#[case(..)]` attributes, so rstest named the
//! generated tests `case_1` to `case_N`, which says nothing about the row
//! that failed. Each row is now named after its first-column value, prefixed
//! with the Examples block name when the block has one, and emitted as
//! rstest's named form `#[case::<name>(..)]`; rstest then reports the test as
//! `case_<n>_<name>`.
//!
//! Because rstest joins the name onto `case_<n>_`, a name must not start with
//! an underscore: `case_1__5` would trip the `non_snake_case` lint in crates
//! that deny warnings. Labels that begin with a digit therefore gain a `v_`
//! prefix (`5` becomes `v_5`), and Rust keywords gain a trailing underscore
//! (`type` becomes `type_`).

use std::collections::HashSet;

use crate::utils::ident::sanitize_ident;

/// Fallback name for a row whose label sanitizes to nothing.
const UNNAMED_ROW: &str = "row";

/// Allocates unique case names across every Examples block of one outline.
#[derive(Debug, Default)]
pub(crate) struct CaseNamer {
    /// Names handed out so far.
    used: HashSet<String>,
}

impl CaseNamer {
    /// Return the unique case name for a row of the named Examples block.
    ///
    /// # Examples
    ///
    /// ```rust,ignore
    /// let mut namer = CaseNamer::default();
    /// assert_eq!(namer.name(None, &["Alice".into()]), "alice");
    /// assert_eq!(namer.name(None, &["alice".into()]), "alice_2");
    /// assert_eq!(namer.name(Some("Edge cases"), &["".into()]), "edge_cases");
    /// ```
    pub(crate) fn name(&mut self, examples_name: Option<&str>, row: &[String]) -> String {
        let base = row_label(examples_name, row);
        let mut candidate = base.clone();
        let mut suffix = 2usize;
        while self.used.contains(&candidate) {
            candidate = format!("{base}_{suffix}");
            suffix += 1;
        }
        self.used.insert(candidate.clone());
        candidate
    }
}

/// Sanitize the Examples block name and first cell into one identifier.
fn row_label(examples_name: Option<&str>, row: &[String]) -> String {
    let first_cell = row.first().map_or("", String::as_str);
    let raw = examples_name.map_or_else(
        || first_cell.to_owned(),
        |prefix| format!("{prefix} {first_cell}"),
    );
    without_leading_underscore(sanitize_ident(&raw))
}

/// Replace the leading underscore `sanitize_ident` adds to empty labels,
/// digit-leading labels, and keywords with a form rstest can append to
/// `case_<n>_` without producing a double underscore.
fn without_leading_underscore(ident: String) -> String {
    match ident.strip_prefix('_') {
        None => ident,
        Some("") => UNNAMED_ROW.to_owned(),
        Some(rest) if rest.starts_with(|c: char| c.is_ascii_digit()) => format!("v_{rest}"),
        Some(keyword) => format!("{keyword}_"),
    }
}

#[cfg(test)]
mod tests {
    //! Unit tests for outline case naming.

    use rstest::rstest;

    use super::*;

    fn row(cells: &[&str]) -> Vec<String> { cells.iter().map(|&cell| cell.to_owned()).collect() }

    #[rstest]
    #[case::first_cell(None, &["Alice", "x"], "alice")]
    #[case::punctuation(None, &["a-b c!", "x"], "a_b_c")]
    #[case::leading_digit(None, &["5"], "v_5")]
    #[case::keyword(None, &["type"], "type_")]
    #[case::empty(None, &[""], "row")]
    #[case::block_prefix(Some("Edge cases"), &["5"], "edge_cases_5")]
    #[case::block_prefix_empty_cell(Some("Edge cases"), &[""], "edge_cases")]
    fn names_rows(
        #[case] examples_name: Option<&str>,
        #[case] cells: &[&str],
        #[case] expected: &str,
    ) {
        assert_eq!(
            CaseNamer::default().name(examples_name, &row(cells)),
            expected
        );
    }

    #[test]
    fn dedupes_repeated_names() {
        let mut namer = CaseNamer::default();
        let allocated: Vec<_> = [&["same"][..], &["Same"], &[""], &[""], &["same_2"]]
            .iter()
            .map(|cells| namer.name(None, &row(cells)))
            .collect();
        assert_eq!(allocated, ["same", "same_2", "row", "row_2", "same_2_2"]);
    }
}
