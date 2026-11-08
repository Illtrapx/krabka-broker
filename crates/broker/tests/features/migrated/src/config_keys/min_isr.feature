Feature: Effective minimum ISR resolution
  A topic override wins over the cluster default and Kafka's default of one.
  Invalid stored values fall back, and the replication factor caps the result.

  Scenario Outline: Minimum ISR follows override precedence and cannot exceed replication
    Given topic min.insync.replicas is <topic> and the cluster default is <cluster>
    And the topic's replication factor is <replicas>
    When the broker resolves the topic's effective minimum ISR
    Then the effective minimum ISR is <minimum>

    Examples:
      | case                                       | topic | cluster | replicas | minimum |
      | the Kafka default                          | unset | unset   | 3        | 1       |
      | the cluster setting                        | unset | 2       | 3        | 2       |
      | a topic setting beats the cluster          | 3     | 2       | 3        | 3       |
      | a non-numeric topic setting                | many  | unset   | 3        | 1       |
      | a topic setting is capped at replication   | 5     | unset   | 3        | 3       |
      | a cluster setting is capped at replication | unset | 9       | 2        | 2       |
