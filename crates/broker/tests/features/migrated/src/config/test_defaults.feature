Feature: Internal topic durability for test clusters
  Small clusters remain startable without claiming more replicas than exist.
  Larger clusters retain Kafka's default replication and minimum-ISR ceilings.

  Scenario Outline: Internal topic durability grows with the cluster up to Kafka's defaults
    Given the test cluster has <brokers> brokers
    When internal topic durability is sized for the cluster
    Then offsets, transactions, barriers, and share state replicate <replication> times with transaction and share minimum ISR <minimum>

    Examples:
      | case                              | brokers | replication | minimum |
      | a single broker                   | 1       | 1           | 1       |
      | two brokers                       | 2       | 2           | 1       |
      | three brokers reach the defaults  | 3       | 3           | 2       |
      | five brokers stay at the defaults | 5       | 3           | 2       |
