# krabka patches to rstest-bdd 0.6.0

This dependency branch carries upstream rstest-bdd source at
`72fb22635670e456545ca368805ba4c1c9d7bd69` (the published 0.6.0 revision).
The upstream ISC license and attribution are retained. Upstream GitHub workflows
are omitted from this source distribution.

krabka consumes only `crates/rstest-bdd-macros` from this branch; the runtime
crates come from crates.io 0.6.0. Every patch below therefore changes the
proc-macro crate alone, and generated code uses only the public API of the
published runtime.

## Fixture guard lifetimes

The proc-macro patch releases each generated fixture borrow guard immediately
after the synchronous or asynchronous step invocation, before converting its
outcome into reporting or error values. Fixtures themselves remain alive for
the scenario. This shortens the borrow to its actual operation and passes
Clippy's significant-drop-tightening check without suppressing the lint.

The proc-macro package uses the published 0.6.0 harness, patterns and policy
support crates, so consuming this Git patch does not introduce duplicate Git
copies of runtime support crates.

## Outline tables without const indexing

Data-table metadata uses explicit array-to-slice coercions instead of range
indexing. This permits structured tables (including Background tables) inside
Scenario Outlines on stable Rust, without requiring const Index support.

## `Rule:` blocks

Upstream silently dropped every scenario declared under a `Rule:`, because
`gherkin` stores them in `Feature::rules` and the macros read only
`Feature::scenarios`. The feature loader now flattens rule scenarios into the
scenario list before caching the feature:

- steps run in the order feature `Background`, rule `Background`, scenario steps;
- rule tags are merged into the scenario tags, so tag filters, `@allow_skipped`, and runtime
  scenario tags inherit them;
- `scenarios!` names rule scenarios `{feature_stem}_{rule}_{scenario}`, while names of scenarios
  outside any rule are unchanged;
- `#[scenario]` selection by `name` or `index` finds rule scenarios, whose indexes follow the
  feature-level scenarios in file order.

krabka's Gherkin house style groups scenarios under `Rule:`, so without this
patch those scenarios never ran.

## `*` bullet steps

`gherkin` types every `*` step as `Given`, so a bullet after a `When` or
`Then` failed step lookup. A `*` bullet now continues the previous primary
keyword, as an `And` does and as Cucumber specifies. A bullet that precedes
every primary keyword has nothing to continue, so it stays a `Given`.

## All-empty Examples rows

Upstream dropped Examples rows whose cells were all empty, but it filtered
them after numbering the cases and again when building the substituted step
table. Every later row then ran another row's steps. Such rows are now real
cases, as in Cucumber, because empty strings are legitimate boundary inputs.
Case indexes and the substituted step table both enumerate every row, so
they stay aligned.

## Outline case names

Upstream emitted anonymous `#[case(..)]` attributes, so outline tests were
named `case_1` to `case_N`, which says nothing about the failing row. Each
row now uses rstest's named form `#[case::<name>(..)]`, so rstest reports
`case_<n>_<name>`. The name is the sanitized first-column value, prefixed
with the sanitized Examples block name when the block has one, and
deduplicated with `_2`, `_3`, and so on. Names never start with an
underscore, because `case_1__5` would trip `non_snake_case` in crates that
deny warnings: digit-leading values gain a `v_` prefix (`5` becomes `v_5`),
keywords gain a trailing underscore, and empty values become `row`.

## Validation

All upstream proc-macro unit tests pass with Clippy clean (all warnings
denied), alongside the upstream behavioural suite. Each krabka patch adds unit
tests and a behavioural test under `crates/rstest-bdd/tests`, with feature
files under `crates/rstest-bdd/tests/features/krabka`.
