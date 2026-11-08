Feature: Kafka-compatible key partitioning
  Brokers and Kafka clients must agree on the hash and destination partition
  for the same key, including keys shorter than a four-byte hash block.

  Scenario Outline: Murmur2 preserves Kafka's reference vectors at every remainder length
    Given the Kafka hash key is <key>
    When the key is hashed with Kafka Murmur2
    Then the unsigned hash is <hash>

    Examples:
      | case                   | key     | hash       |
      | an empty key           | (empty) | 275646681  |
      | a one-byte remainder   | a       | 2731586172 |
      | a two-byte remainder   | ab      | 316155434  |
      | a three-byte remainder | abc     | 479470107  |
      | one whole block        | abcd    | 2971317748 |
      | a block and one byte   | abcde   | 461995741  |

  Scenario Outline: Transaction keys select the same partition as Kafka clients
    Given the Kafka hash key is <key>
    And the destination topic has <partitions> partitions
    When Kafka's absolute-hash partition rule is applied
    Then the destination partition is <partition>

    Examples:
      | case                      | key            | partitions | partition |
      | a transactional id        | my-tid         | 50         | 43        |
      | a producer-style id       | producer-1     | 50         | 45        |
      | a longer transactional id | tx-orders-prod | 50         | 26        |
      | a small partition count   | abcde          | 7          | 4         |
