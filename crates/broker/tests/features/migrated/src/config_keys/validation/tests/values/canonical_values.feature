Feature: Topic canonicalization follows Kafka ConfigDef parsing
  Whitespace, booleans, doubles, lists, and replica-throttle syntax retain their canonical outcomes.

  Scenario Outline: Topic canonicalization follows Kafka ConfigDef parsing
    Given a topic alteration supplies key <key> and quoted value <value>
    When the supplied topic value is canonicalized in released mode
    Then the canonical topic outcome is <expected>

    Examples:
      | case                        | key | value | expected |
      | an uppercase boolean        | preallocate | "TRUE" | "true" |
      | a padded boolean            | remote.log.copy.disable | " false " | "false" |
      | a non-boolean word          | preallocate | "yes" | rejected |
      | a padded long               | retention.ms | " 1000 " | "1000" |
      | a trailing space on an int  | segment.bytes | "1048576 " | "1048576" |
      | a leading space on a string | compression.type | " gzip" | "gzip" |
      | a double suffix             | min.cleanable.dirty.ratio | "0.5d" | "0.5" |
      | an integral double          | min.cleanable.dirty.ratio | "1" | "1.0" |
      | a padded list               | cleanup.policy | " compact , delete " | "compact,delete" |
      | a blank list                | cleanup.policy | " " | "" |
      | a blank replica list        | leader.replication.throttled.replicas | " " | "" |
      | a padded wildcard           | leader.replication.throttled.replicas | " * " | "*" |
      | an empty replica entry      | leader.replication.throttled.replicas | "0:1,,1:2" | "0:1,,1:2" |
      | a negative partition        | leader.replication.throttled.replicas | "-1:1" | rejected |
      | a signed partition          | leader.replication.throttled.replicas | "+0:1" | rejected |
      | spaces around the colon     | follower.replication.throttled.replicas | "0 : 1" | rejected |
