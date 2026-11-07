Feature: Failure context
  A failing step reports where it was written.

  Scenario: Failing bullet step
    Given the diagnostics fixture is ready
    * the bullet step fails

  Rule: Outline failures
    Scenario Outline: Failing row step
      Given the diagnostics fixture is ready
      And the value <value> is rejected

      Examples:
        | value |
        | 42    |
