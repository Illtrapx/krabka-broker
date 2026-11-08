Feature: DescribeLogDirs filters the union of explicitly requested partitions
  Scenario Outline: Null topics mean all partitions while explicit lists limit the result
    Given the log directory request lists <requested>
    When the log directory filter checks topic <topic> partition <partition>
    Then that log partition is included <expected>
    Examples:
      | case                           | requested  | topic | partition | expected |
      | null topics include everything | all topics | any   | 9         | true     |
      | a listed partition             | t:0,2      | t     | 2         | true     |
      | an unlisted partition          | t:0,2      | t     | 1         | false    |
      | an unlisted topic              | t:0        | u     | 0         | false    |
      | a topic with no partitions     | t:none     | t     | 0         | false    |
      | a topic listed twice           | t:0;t:1    | t     | 0         | true     |
