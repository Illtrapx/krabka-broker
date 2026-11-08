Feature: AlterConfigs validates complete client metrics subscription replacements
  Scenario Outline: Replacement failures preserve Kafka exception codes and messages
    Given client metrics subscription <subscription> is replaced with key <key> value <value>
    When the authoritative client metrics replacement record is built
    Then the client metrics replacement fails with code <code> and message <message>
    Examples:
      | case                       | subscription | key         | value | code | message                                                                            |
      | interval below the minimum | sub-a        | interval.ms | 5     | 42   | Invalid value 5 for interval.ms, interval must be between 100 and 3600000 (1 hour) |
      | unknown key                | sub-a        | bogus.key   | x     | 42   | Unknown client metrics configuration: bogus.key                                    |
      | non-numeric interval       | sub-a        | interval.ms | abc   | 40   | Invalid value abc for configuration interval.ms: Not a number of type INT          |
      | empty subscription name    | empty        | none        | none  | 42   | Subscription name can't be empty                                                   |
