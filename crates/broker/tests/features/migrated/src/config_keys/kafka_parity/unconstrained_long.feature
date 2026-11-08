Feature: Kafka LONG topic values without an invented lower bound
  retention.bytes has no range validator in Kafka: every representable LONG,
  including minus two, survives a MirrorMaker configuration replay.

  Scenario Outline: Unconstrained retention bytes accepts the complete LONG domain
    Given an operator alters topic key retention.bytes to quoted value <value>
    When the released topic alteration validator checks the operator value
    Then the individual topic alteration is accepted

    Examples:
      | case                          | value |
      | the smallest long             | "-9223372036854775808" |
      | a negative below the sentinel | "-2" |
      | the unlimited sentinel        | "-1" |
      | zero                          | "0" |
      | the largest long              | "9223372036854775807" |
