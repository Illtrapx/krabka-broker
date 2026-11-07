@lifecycle
Feature: Lifecycle tags
  Tests whose inherited tags match `ignore_tags` are generated as ignored
  tests rather than dropped.

  Scenario: Ready scenario runs
    Then the lifecycle step passes

  @formulated
  Scenario: Formulated scenario is ignored
    Then the lifecycle step passes

  @inprogress
  Rule: Work in progress
    Scenario: Rule scenario inherits the ignore
      Then the lifecycle step passes

  Rule: Mixed rows
    Scenario Outline: Outline rows are ignored per block
      Then the lifecycle step passes for <state>

      Examples: ready
        | state |
        | done  |

      @formulated
      Examples: planned
        | state   |
        | planned |
