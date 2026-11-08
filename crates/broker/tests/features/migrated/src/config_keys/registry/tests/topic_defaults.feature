Feature: Kafka topic configuration defaults
  A topic without overrides reports Kafka's exact defaults, including empty
  throttle lists, inherited local-retention sentinels, and unlimited long values.

  Scenario Outline: Topic default values agree with Apache Kafka
    Given the registered topic configuration key is <key>
    When DescribeConfigs reads the registered key's metadata
    Then the registered key's quoted Kafka default is <value>

    Examples:
      | case                                                | key | value |
      | the retention.ms default                            | retention.ms | "604800000" |
      | the retention.bytes default                         | retention.bytes | "-1" |
      | the segment.bytes default                           | segment.bytes | "1073741824" |
      | the cleanup.policy default                          | cleanup.policy | "delete" |
      | the compression.type default                        | compression.type | "producer" |
      | the min.insync.replicas default                     | min.insync.replicas | "1" |
      | the unclean.leader.election.enable default          | unclean.leader.election.enable | "false" |
      | the remote.storage.enable default                   | remote.storage.enable | "false" |
      | the local.retention.ms default                      | local.retention.ms | "-2" |
      | the local.retention.bytes default                   | local.retention.bytes | "-2" |
      | the delete.retention.ms default                     | delete.retention.ms | "86400000" |
      | the leader.replication.throttled.replicas default   | leader.replication.throttled.replicas | "" |
      | the follower.replication.throttled.replicas default | follower.replication.throttled.replicas | "" |
      | the segment.ms default                              | segment.ms | "604800000" |
      | the segment.index.bytes default                     | segment.index.bytes | "10485760" |
      | the segment.jitter.ms default                       | segment.jitter.ms | "0" |
      | the min.compaction.lag.ms default                   | min.compaction.lag.ms | "0" |
      | the max.compaction.lag.ms default                   | max.compaction.lag.ms | "9223372036854775807" |
      | the min.cleanable.dirty.ratio default               | min.cleanable.dirty.ratio | "0.5" |
      | the file.delete.delay.ms default                    | file.delete.delay.ms | "60000" |
      | the flush.messages default                          | flush.messages | "9223372036854775807" |
      | the flush.ms default                                | flush.ms | "9223372036854775807" |
      | the index.interval.bytes default                    | index.interval.bytes | "4096" |
      | the preallocate default                             | preallocate | "false" |
      | the message.timestamp.type default                  | message.timestamp.type | "CreateTime" |
      | the message.timestamp.after.max.ms default          | message.timestamp.after.max.ms | "3600000" |
      | the message.timestamp.before.max.ms default         | message.timestamp.before.max.ms | "9223372036854775807" |
