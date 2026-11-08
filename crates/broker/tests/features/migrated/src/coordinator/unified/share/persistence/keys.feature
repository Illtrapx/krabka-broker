Feature: Share group metadata key schema
  Scenario Outline: Record kinds use Kafka compacted-log API keys
    Given the Share compacted log record kind is <kind>
    When the Share coordinator selects the record API key
    Then the Share record API key is <version>
    Examples:
      | case                           | kind                           | version |
      | member metadata                | member-metadata                | 10      |
      | group metadata                 | group-metadata                 | 11      |
      | target assignment metadata     | target-assignment-metadata     | 12      |
      | target assignment member       | target-assignment-member       | 13      |
      | current member assignment      | current-member-assignment      | 14      |
      | group state partition metadata | group-state-partition-metadata | 15      |
  Scenario Outline: Group and member identifiers use Kafka non-flexible strings
    Given a Share <kind> metadata key for group g1 and member <member>
    When the Share coordinator encodes the metadata key
    Then the Share metadata key has exact Kafka bytes <hex>
    Examples:
      | case                               | kind   | member | hex                  |
      | a group key has no member          | group  | absent | 000b00026731         |
      | a member key carries its member id | member | m1     | 000a0002673100026d31 |
