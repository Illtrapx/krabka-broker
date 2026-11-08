Feature: Streams topology descriptions validate node shapes and preserve node data
  Scenario: A valid topology push is described with Kafka node fields and list order
    Given a topology push has source processor and sink nodes plus a source-processor global store
    When the coordinator validates the pushed topology and renders its describe response
    Then the describe response preserves every node field and deduplicates each list in original order
  Scenario Outline: Unknown node types and malformed global stores use Kafka validation precedence
    Given a topology push has subtopology node type <node> global source type <source> and global processor type <processor>
    When the coordinator validates the pushed topology and renders its describe response
    Then the topology push is rejected with Kafka message <message>
    Examples:
      | case                                                    | node   | source | processor | message                                                         |
      | node type zero is unknown                               | 0      | absent | absent    | Unknown topology node type: 0                                   |
      | node type four is unknown                               | 4      | absent | absent    | Unknown topology node type: 4                                   |
      | a negative node type is unknown                         | -1     | absent | absent    | Unknown topology node type: -1                                  |
      | a global store of a sink and a processor                | absent | 3      | 2         | Global store must be composed of a source and a processor node. |
      | a global store of two sources                           | absent | 1      | 1         | Global store must be composed of a source and a processor node. |
      | an unknown processor in a global store                  | absent | 1      | 7         | Unknown topology node type: 7                                   |
      | an unknown node type wins over a malformed global store | 9      | 3      | 2         | Unknown topology node type: 9                                   |
