@stage:draft
Feature: Draft lifecycle
  Feature tags are inherited, including tags with colons.

  Scenario: Draft scenario is ignored
    Then the lifecycle step passes
