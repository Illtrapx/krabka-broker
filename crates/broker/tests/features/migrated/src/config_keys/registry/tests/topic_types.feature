Feature: Kafka topic configuration types
  Each registered topic key retains the ConfigDef type read by a Kafka
  AdminClient from DescribeConfigs, rather than guessing a type from its value.

  Scenario Outline: Registered topic key types agree with Apache Kafka
    Given the registered topic configuration key is <key>
    When DescribeConfigs reads the registered key's metadata
    Then the registered key's Kafka type is <kind>

    Examples:
      | case                                              | key | kind |
      | retention.ms is a long                            | retention.ms | long |
      | retention.bytes is a long                         | retention.bytes | long |
      | segment.bytes is a int                            | segment.bytes | int |
      | cleanup.policy is a list                          | cleanup.policy | list |
      | compression.type is a string                      | compression.type | string |
      | min.insync.replicas is a int                      | min.insync.replicas | int |
      | unclean.leader.election.enable is a boolean       | unclean.leader.election.enable | boolean |
      | remote.storage.enable is a boolean                | remote.storage.enable | boolean |
      | local.retention.ms is a long                      | local.retention.ms | long |
      | local.retention.bytes is a long                   | local.retention.bytes | long |
      | delete.retention.ms is a long                     | delete.retention.ms | long |
      | leader.replication.throttled.replicas is a list   | leader.replication.throttled.replicas | list |
      | follower.replication.throttled.replicas is a list | follower.replication.throttled.replicas | list |
      | segment.ms is a long                              | segment.ms | long |
      | segment.index.bytes is a int                      | segment.index.bytes | int |
      | segment.jitter.ms is a long                       | segment.jitter.ms | long |
      | min.compaction.lag.ms is a long                   | min.compaction.lag.ms | long |
      | max.compaction.lag.ms is a long                   | max.compaction.lag.ms | long |
      | min.cleanable.dirty.ratio is a double             | min.cleanable.dirty.ratio | double |
      | file.delete.delay.ms is a long                    | file.delete.delay.ms | long |
      | flush.messages is a long                          | flush.messages | long |
      | flush.ms is a long                                | flush.ms | long |
      | index.interval.bytes is a int                     | index.interval.bytes | int |
      | preallocate is a boolean                          | preallocate | boolean |
      | message.timestamp.type is a string                | message.timestamp.type | string |
      | message.timestamp.after.max.ms is a long          | message.timestamp.after.max.ms | long |
      | message.timestamp.before.max.ms is a long         | message.timestamp.before.max.ms | long |
