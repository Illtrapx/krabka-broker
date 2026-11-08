Feature: Kafka topic INT keys preserve signed 32-bit domains
  A valid wider LONG never sneaks into an INT topic key.

  Scenario Outline: Kafka topic INT keys preserve signed 32-bit domains
    Given a topic alteration supplies key <key> and quoted value <value>
    When the released per-key topic validator reads the supplied value
    Then the supplied topic value is accepted <accepted>

    Examples:
      | case                             | key | value | accepted |
      | the largest segment              | segment.bytes | "2147483647" | true |
      | a segment past the int range     | segment.bytes | "2147483648" | false |
      | a segment at the long maximum    | segment.bytes | "9223372036854775807" | false |
      | the largest minimum ISR          | min.insync.replicas | "2147483647" | true |
      | a minimum ISR past the int range | min.insync.replicas | "2147483648" | false |
      | a zero minimum ISR               | min.insync.replicas | "0" | false |
      | a negative minimum ISR           | min.insync.replicas | "-1" | false |
