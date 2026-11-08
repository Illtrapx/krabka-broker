Feature: Kafka topic value rejection boundaries
  Compatibility includes Kafka's refusals, not merely its key roster: unknown
  names, invalid codec bounds, negative batch limits, and invalid LONGs stay invalid.

  Scenario Outline: Values refused by Kafka remain refused by the broker
    Given an operator alters topic key <key> to quoted value <value>
    When the released topic alteration validator checks the operator value
    Then the individual topic alteration is refused

    Examples:
      | case                            | key | value |
      | a removed key                   | message.downconversion.enable | "true" |
      | an unknown key                  | totally.made.up | "1" |
      | gzip below its range            | compression.gzip.level | "0" |
      | lz4 above its range             | compression.lz4.level | "18" |
      | lz4 below its range             | compression.lz4.level | "0" |
      | zstd below its range            | compression.zstd.level | "-131073" |
      | zstd above its range            | compression.zstd.level | "23" |
      | a negative message size         | max.message.bytes | "-1" |
      | a segment under one mebibyte    | segment.bytes | "1048575" |
      | a zero segment                  | segment.bytes | "0" |
      | a producer-only compression     | compression.type | "none" |
      | a retention past the long range | retention.bytes | "9223372036854775808" |
