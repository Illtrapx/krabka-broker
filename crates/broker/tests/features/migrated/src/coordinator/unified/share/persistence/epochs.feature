Feature: Share group and assignment epoch compatibility
  Scenario Outline: Persist group epochs with Kafka metadata hash fields
    Given the Share group epoch is <epoch> with metadata hash <hash>
    And Kafka encodes that Share epoch record as <hex>
    When the coordinator writes the Share epoch record and reads Kafka bytes
    Then the Share epoch bytes match Kafka exactly and all epoch fields are recovered
    Examples:
      | case            | epoch | hash                | hex                            |
      | a zero hash     | 7     | 0                   | 000000000007000000000000000000 |
      | a negative hash | 2     | -556879919459959918 | 000000000002f84590a9ea0a7b9200 |
  Scenario Outline: Assignment completion timestamps use Kafka optional tags
    Given the Share assignment epoch is 12 with completion timestamp <timestamp>
    And Kafka encodes that Share epoch record as <hex>
    When the coordinator writes the Share epoch record and reads Kafka bytes
    Then the Share epoch bytes match Kafka exactly and all epoch fields are recovered
    Examples:
      | case                                  | timestamp     | hex                                |
      | an unknown completion time is omitted | 0             | 00000000000c00                     |
      | a known completion time is tagged     | 1791331200000 | 00000000000c010008000001a113a8ec00 |
