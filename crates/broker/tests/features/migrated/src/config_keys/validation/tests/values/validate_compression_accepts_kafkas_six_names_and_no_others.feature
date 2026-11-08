Feature: Kafka compression names are exactly the six broker codec names
  Producer-side none, uppercase names, and empty values remain invalid.

  Scenario Outline: Kafka compression names are exactly the six broker codec names
    Given a topic alteration supplies key compression.type and quoted value <value>
    When the released per-key topic validator reads the supplied value
    Then the supplied topic value is accepted <accepted>

    Examples:
      | case                 | value | accepted |
      | the producer codec   | "producer" | true |
      | no compression       | "uncompressed" | true |
      | gzip                 | "gzip" | true |
      | snappy               | "snappy" | true |
      | lz4                  | "lz4" | true |
      | zstd                 | "zstd" | true |
      | a producer-only name | "none" | false |
      | an empty name        | "" | false |
      | an uppercase name    | "GZIP" | false |
      | a leading space      | " gzip" | true |
