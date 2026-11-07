Feature: Star bullets
  A `*` bullet continues the previous primary keyword, so it can follow a
  When or a Then. A bullet before any primary keyword acts as a Given.

  Background:
    * the bullet journal is open

  Scenario: Bullets inherit the preceding keyword
    * a precondition is journalled
    When an action is journalled
    * another action is journalled
    Then an outcome is journalled
    * another outcome is journalled
