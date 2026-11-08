Feature: Registered Kafka topic names retain both acceptance and refusal examples
  Each name is recognized and enforces the same legal and illegal samples as Kafka.

  Scenario Outline: Registered Kafka topic names retain both acceptance and refusal examples
    Given topic key <key> has quoted legal sample <legal> and quoted illegal sample <illegal>
    When the broker recognizes the topic key and validates both named samples
    Then the key is recognized, its legal sample is accepted, and its illegal sample is refused

    Examples:
      | case                                        | key                             | legal                 | illegal     |
      | the segment.ms samples                      | segment.ms                      | "60000"               | "0"         |
      | the segment.index.bytes samples             | segment.index.bytes             | "10485760"            | "3"         |
      | the segment.jitter.ms samples               | segment.jitter.ms               | "0"                   | "-1"        |
      | the min.compaction.lag.ms samples           | min.compaction.lag.ms           | "0"                   | "-1"        |
      | the max.compaction.lag.ms samples           | max.compaction.lag.ms           | "9223372036854775807" | "0"         |
      | the min.cleanable.dirty.ratio samples       | min.cleanable.dirty.ratio       | "0.5"                 | "2.0"       |
      | the file.delete.delay.ms samples            | file.delete.delay.ms            | "60000"               | "-1"        |
      | the flush.messages samples                  | flush.messages                  | "10000"               | "0"         |
      | the flush.ms samples                        | flush.ms                        | "1000"                | "-1"        |
      | the index.interval.bytes samples            | index.interval.bytes            | "4096"                | "-1"        |
      | the preallocate samples                     | preallocate                     | "true"                | "yes"       |
      | the message.timestamp.type samples          | message.timestamp.type          | "LogAppendTime"       | "WallClock" |
      | the message.timestamp.after.max.ms samples  | message.timestamp.after.max.ms  | "3600000"             | "-1"        |
      | the message.timestamp.before.max.ms samples | message.timestamp.before.max.ms | "3600000"             | "-1"        |
