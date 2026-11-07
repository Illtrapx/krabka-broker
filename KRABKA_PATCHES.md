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

## Validation

All upstream proc-macro unit tests pass with Clippy clean (all warnings
denied), alongside the upstream behavioural suite. Each krabka patch adds unit
tests and a behavioural test under `crates/rstest-bdd/tests`, with feature
files under `crates/rstest-bdd/tests/features/krabka`.
