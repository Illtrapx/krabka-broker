Feature: Placeholders bind by name
  Step parameters receive the value of the placeholder they are named
  after, whatever order they are declared in.

  Scenario: Reordered parameters receive their own values
    Given the order "alpha" then 2 then gamma
    When the renamed order "delta" then 5 is recorded
    Then the journal reads "alpha 2 gamma, delta 5"
