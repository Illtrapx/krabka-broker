Feature: Consumer epoch records persist Kafka metadata hashes
  Scenario Outline: A consumer group writes the Kafka topic metadata hash
    Given metadata contains the two-partition orders topic <topic_exists>
    When a consumer joins group g subscribed to orders and the coordinator persists its epoch
    Then group epoch 2 carries exact Kafka metadata hash <hash>
    Examples:
      | case                           | topic_exists | hash                |
      | an existing topic is hashed    | true         | 2418189869542540743 |
      | a missing topic hashes to zero | false        | 0                   |
