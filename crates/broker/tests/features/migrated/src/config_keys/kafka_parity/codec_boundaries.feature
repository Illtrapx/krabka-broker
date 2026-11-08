Feature: Kafka compression-level topic bounds
  Each codec accepts the same minimum and maximum settings as Kafka's validator.

  Scenario Outline: Compression level boundary values remain accepted
    Given an operator alters topic key <key> to quoted value <value>
    When the released topic alteration validator checks the operator value
    Then the individual topic alteration is accepted

    Examples:
      | case                   | key | value |
      | the gzip default       | compression.gzip.level | "-1" |
      | the lowest gzip level  | compression.gzip.level | "1" |
      | the highest gzip level | compression.gzip.level | "9" |
      | the lowest lz4 level   | compression.lz4.level | "1" |
      | the highest lz4 level  | compression.lz4.level | "17" |
      | the lowest zstd level  | compression.zstd.level | "-131072" |
      | the highest zstd level | compression.zstd.level | "22" |
