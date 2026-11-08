Feature: Consumer metadata key compatibility
  Scenario Outline: Persist and recover group and expression key identifiers
    Given a consumer <kind> key for group <group> and expression <expression>
    When the coordinator encodes the consumer key and parses its Kafka key version
    Then the consumer key bytes are <hex> and all original key fields survive decoding
    Examples:
      | case                                            | kind               | group | expression | hex                  |
      | a partition metadata key has no expression      | partition-metadata | grp   | absent     | 00040003677270       |
      | a regular expression key carries its expression | regular-expression | g     | a.*        | 00100001670003612e2a |
