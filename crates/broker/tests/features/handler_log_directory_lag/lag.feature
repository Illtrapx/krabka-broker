Feature: DescribeLogDirs reports Kafka current and future offset lag
  Scenario Outline: Current lag is unknown without a local log and otherwise clamps at zero
    Given the current local log for topic t partition 0 has five records
    When the current log lag is requested for topic <topic> partition 0
    Then the log lag is <expected> and the current log end remains 5
    Examples:
      | case               | topic | expected |
      | no local log       | ghost | -1       |
      | lag clamps at zero | t     | 0        |

  Scenario Outline: Future lag compares current and future ends without clamping
    Given the current local log for topic t partition 3 has five records
    And the future log for topic <topic> partition 3 has <records> records
    When the future log lag is requested for topic <topic> partition 3
    Then the log lag is <expected> and the current log end remains 5
    Examples:
      | case              | topic | records | expected |
      | no local log      | ghost | 2       | -1       |
      | future log behind | t     | 2       | 3        |
      | future log ahead  | t     | 7       | -2       |
