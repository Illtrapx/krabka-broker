Feature: Kafka segment bytes has a one-MiB floor
  Public segment sizing honors Kafka INT parsing and its one-MiB floor.

  Scenario Outline: Kafka segment bytes has a one-MiB floor
    Given a topic alteration supplies key segment.bytes and quoted value <value>
    When the released per-key topic validator reads the supplied value
    Then the supplied topic value is accepted <accepted>

    Examples:
      | case                                  | value | accepted |
      | zero                                  | "0" | false |
      | one byte                              | "1" | false |
      | a few bytes                           | "14" | false |
      | one byte under the floor              | "1048575" | false |
      | the floor                             | "1048576" | true |
      | one gibibyte                          | "1073741824" | true |
      | not a number                          | "not-a-number" | false |
