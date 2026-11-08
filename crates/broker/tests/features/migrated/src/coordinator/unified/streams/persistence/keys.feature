Feature: Streams group metadata key schema
  Scenario Outline: Record kinds use Kafka compacted-log API keys
    Given the Streams compacted log record kind is <kind>
    When the Streams coordinator selects the record API key
    Then the Streams record API key is <version>
    Examples:
      | case                       | kind                       | version |
      | group metadata             | group-metadata             | 17      |
      | member metadata            | member-metadata            | 19      |
      | target assignment metadata | target-assignment-metadata | 20      |
      | target assignment member   | target-assignment-member   | 21      |
      | current member assignment  | current-member-assignment  | 22      |
      | topology                   | topology                   | 23      |
  Scenario Outline: Group and member identifiers use Kafka non-flexible strings
    Given a Streams <kind> metadata key for group g1 and member <member>
    When the Streams coordinator encodes the metadata key
    Then the Streams metadata key has exact Kafka bytes <hex>
    Examples:
      | case                               | kind   | member | hex                  |
      | a group key has no member          | group  | absent | 001100026731         |
      | a member key carries its member id | member | m1     | 00130002673100026d31 |
