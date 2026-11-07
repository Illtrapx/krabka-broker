//! Binding step-function parameters to pattern captures by placeholder name.
//!
//! A step pattern's captures are numbered in pattern order, while a step
//! function's parameters appear in declaration order. Upstream paired them by
//! position, so writing `fn step(b: i32, a: i32)` for the pattern
//! `"{a} then {b}"` silently swapped the values. Each parameter now takes the
//! capture of the placeholder it claimed during classification (its
//! `#[from(...)]` name, or its own name without one leading underscore).
//! Position is only the fallback for a parameter whose name matches no
//! remaining placeholder, which keeps unnamed or synthetic bindings working
//! as before. `#[step_args]` structs bind their fields by name separately.

use proc_macro2::TokenStream as TokenStream2;
use rstest_bdd_patterns::requires_quote_stripping;

use super::{StepMeta, bindings::BoundStepArg, gen_step_parses};

/// Generated step argument parses and quote-stripping indicator.
pub(super) struct StepArgParseResult {
    /// Stores the internal `step_arg_parses` value.
    pub(super) step_arg_parses: Vec<TokenStream2>,
    /// Stores the internal `has_step_arg_quote_strip` value.
    pub(super) has_step_arg_quote_strip: bool,
}

/// Input data for building step argument parse expressions.
#[derive(Copy, Clone)]
pub(super) struct StepArgParseInputs<'a> {
    /// Step arguments in declaration order.
    pub(super) step_args: &'a [BoundStepArg<'a>],
    /// Capture accessors in pattern order.
    pub(super) all_captures: &'a [TokenStream2],
    /// Placeholder names in pattern order, aligned with `all_captures`.
    pub(super) placeholder_names: &'a [syn::LitStr],
    /// Optional type hints, aligned with `placeholder_names`.
    pub(super) placeholder_hints: &'a [Option<String>],
}

/// Return the capture index for each step argument, in declaration order.
///
/// Each argument first claims the earliest unclaimed placeholder with its
/// name; arguments left without a match then take the unclaimed placeholders
/// in pattern order.
///
/// # Examples
///
/// ```rust,ignore
/// // pattern "{a} then {b}", parameters (b, a)
/// assert_eq!(capture_indices(&["b", "a"], &["a", "b"]), [1, 0]);
/// ```
fn capture_indices(arg_names: &[&str], placeholder_names: &[String]) -> Vec<usize> {
    let mut unclaimed: Vec<Option<&str>> = placeholder_names
        .iter()
        .map(|name| Some(name.as_str()))
        .collect();
    let by_name: Vec<Option<usize>> = arg_names
        .iter()
        .map(|arg| claim(&mut unclaimed, |name| name == *arg))
        .collect();
    by_name
        .into_iter()
        .map(|idx| idx.or_else(|| claim(&mut unclaimed, |_| true)))
        .enumerate()
        .map(|(position, idx)| idx.unwrap_or(position))
        .collect()
}

/// Claim the first unclaimed placeholder accepted by `accepts`.
fn claim(unclaimed: &mut [Option<&str>], accepts: impl Fn(&str) -> bool) -> Option<usize> {
    let idx = unclaimed
        .iter()
        .position(|slot| slot.is_some_and(&accepts))?;
    if let Some(slot) = unclaimed.get_mut(idx) {
        *slot = None;
    }
    Some(idx)
}

/// Build an error result carrying a compile error at the step pattern.
fn error_result(step_meta: StepMeta<'_>, message: String) -> StepArgParseResult {
    StepArgParseResult {
        step_arg_parses: vec![
            syn::Error::new(step_meta.pattern.span(), message).to_compile_error(),
        ],
        has_step_arg_quote_strip: false,
    }
}

/// Build parsers for step arguments from `StepArgParseInputs` and `StepMeta`.
///
/// When `step_struct_present` is true, the step struct handles argument parsing,
/// so this returns an empty `StepArgParseResult` with no quote-stripping.
pub(super) fn build_step_arg_parses(
    inputs: StepArgParseInputs<'_>,
    step_meta: StepMeta<'_>,
    step_struct_present: bool,
) -> StepArgParseResult {
    let StepArgParseInputs {
        step_args,
        all_captures,
        placeholder_names,
        placeholder_hints,
    } = inputs;
    if step_struct_present {
        return StepArgParseResult {
            step_arg_parses: Vec::new(),
            has_step_arg_quote_strip: false,
        };
    }
    if step_args.len() > all_captures.len() {
        return error_result(
            step_meta,
            format!(
                "step arguments ({}) cannot exceed capture count ({})",
                step_args.len(),
                all_captures.len()
            ),
        );
    }
    if step_args.len() > placeholder_hints.len() {
        return error_result(
            step_meta,
            format!(
                "placeholder hints ({}) must match or exceed step argument count ({})",
                placeholder_hints.len(),
                step_args.len()
            ),
        );
    }

    let arg_names: Vec<&str> = step_args.iter().map(|arg| arg.arg.placeholder).collect();
    let names: Vec<String> = placeholder_names.iter().map(syn::LitStr::value).collect();
    let indices = capture_indices(&arg_names, &names);
    let captures: Vec<TokenStream2> = indices
        .iter()
        .filter_map(|&idx| all_captures.get(idx).cloned())
        .collect();
    let hints: Vec<Option<String>> = indices
        .iter()
        .map(|&idx| placeholder_hints.get(idx).cloned().flatten())
        .collect();
    let has_step_arg_quote_strip = hints
        .iter()
        .any(|hint| requires_quote_stripping(hint.as_deref()));
    let step_arg_parses = gen_step_parses(step_args, &captures, &hints, step_meta);

    StepArgParseResult {
        step_arg_parses,
        has_step_arg_quote_strip,
    }
}

#[cfg(test)]
mod tests {
    //! Unit tests for name-based capture binding.

    use rstest::rstest;

    use super::capture_indices;

    fn names(list: &[&str]) -> Vec<String> { list.iter().map(|&name| name.to_owned()).collect() }

    #[rstest]
    #[case::in_order(&["a", "b"], &["a", "b"], &[0, 1])]
    #[case::reordered(&["b", "a"], &["a", "b"], &[1, 0])]
    #[case::three_reordered(&["c", "a", "b"], &["a", "b", "c"], &[2, 0, 1])]
    #[case::repeated_placeholder(&["x", "y"], &["x", "y", "x"], &[0, 1])]
    #[case::unmatched_falls_back(&["renamed", "b"], &["a", "b"], &[0, 1])]
    #[case::unmatched_takes_free_slot(&["b", "renamed"], &["a", "b"], &[1, 0])]
    fn binds_by_name_with_positional_fallback(
        #[case] args: &[&str],
        #[case] placeholders: &[&str],
        #[case] expected: &[usize],
    ) {
        assert_eq!(capture_indices(args, &names(placeholders)), expected);
    }
}
