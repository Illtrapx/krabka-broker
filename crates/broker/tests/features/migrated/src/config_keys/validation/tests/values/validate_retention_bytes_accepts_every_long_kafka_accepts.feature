Feature: Kafka retention bytes accepts every representable LONG
  No invented range check rejects negative Kafka LONG values or admits overflow.

  Scenario Outline: Kafka retention bytes accepts every representable LONG
    Given a topic alteration supplies key retention.bytes and quoted value <value>
    When the released per-key topic validator reads the supplied value
    Then the supplied topic value is accepted <accepted>

    Examples:
      | case                | value | accepted |
      | unlimited           | "-1" | true |
      | the local sentinel  | "-2" | true |
      | zero                | "0" | true |
      | one gibibyte        | "1073741824" | true |
      | the smallest long   | "-9223372036854775808" | true |
      | the largest long    | "9223372036854775807" | true |
      | past the long range | "9223372036854775808" | false |
      | not a number        | "abc" | false |
