Feature: Consumer group and assignment epoch compatibility
  Scenario Outline: Persist group epochs with Kafka metadata hash fields
    Given the consumer group epoch is <epoch> with metadata hash <hash>
    And Kafka encodes that consumer epoch record as <hex>
    When the coordinator writes the consumer epoch record and reads Kafka bytes
    Then the consumer epoch bytes match Kafka exactly and all epoch fields are recovered
    Examples:
      | case                      | epoch | hash                | hex                                |
      | a zero hash is omitted    | 7     | 0                   | 00000000000700                     |
      | a positive hash is tagged | 7     | 42                  | 000000000007010008000000000000002a |
      | a negative hash is tagged | 2     | -556879919459959918 | 000000000002010008f84590a9ea0a7b92 |
  Scenario Outline: Assignment completion timestamps use Kafka optional tags
    Given the consumer assignment epoch is 12 with completion timestamp <timestamp>
    And Kafka encodes that consumer epoch record as <hex>
    When the coordinator writes the consumer epoch record and reads Kafka bytes
    Then the consumer epoch bytes match Kafka exactly and all epoch fields are recovered
    Examples:
      | case                                  | timestamp     | hex                                |
      | an unknown completion time is omitted | 0             | 00000000000c00                     |
      | a known completion time is tagged     | 1791331200000 | 00000000000c010008000001a113a8ec00 |
