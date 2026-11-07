@rule_feature
Feature: Rule blocks
  Each rule scenario runs the feature background, then the rule background,
  then its own steps, and inherits the rule's tags.

  Background:
    Given the feature background is journalled

  Scenario: Outside any rule
    When the scenario step is journalled
    Then the journal reads "feature, scenario"

  @ordering
  Rule: Ordering
    Background:
      Given the rule background is journalled

    Scenario: Rule scenario follows both backgrounds
      When the scenario step is journalled
      And the scenario step is journalled
      Then the journal reads "feature, rule, scenario, scenario"

    Scenario Outline: Rule outline substitutes placeholders
      When the value <value> is journalled
      Then the journal reads "feature, rule, <value>"

      Examples:
        | value |
        | one   |
        | two   |

  Rule: Failure
    Scenario: Rule scenario reaches its failing step
      Then the rule scenario panics
