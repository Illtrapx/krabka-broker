Feature: Kafka broker configuration types
  Each registered broker key retains the ConfigDef type read by a Kafka
  AdminClient from DescribeConfigs, rather than guessing a type from its value.

  Scenario Outline: Registered broker key types agree with Apache Kafka
    Given the registered broker configuration key is <key>
    When DescribeConfigs reads the registered key's metadata
    Then the registered key's Kafka type is <kind>

    Examples:
      | case                                                                | key | kind |
      | leader.replication.throttled.rate is a long                         | leader.replication.throttled.rate | long |
      | follower.replication.throttled.rate is a long                       | follower.replication.throttled.rate | long |
      | replica.alter.log.dirs.io.max.bytes.per.second is a long            | replica.alter.log.dirs.io.max.bytes.per.second | long |
      | unclean.leader.election.enable is a boolean                         | unclean.leader.election.enable | boolean |
      | remote.list.offsets.request.timeout.ms is a long                    | remote.list.offsets.request.timeout.ms | long |
      | offsets.retention.minutes is a int                                  | offsets.retention.minutes | int |
      | offsets.retention.check.interval.ms is a long                       | offsets.retention.check.interval.ms | long |
      | connections.max.idle.ms is a long                                   | connections.max.idle.ms | long |
      | connections.max.reauth.ms is a long                                 | connections.max.reauth.ms | long |
      | node.id is a int                                                    | node.id | int |
      | transactional.id.expiration.ms is a int                             | transactional.id.expiration.ms | int |
      | transaction.remove.expired.transaction.cleanup.interval.ms is a int | transaction.remove.expired.transaction.cleanup.interval.ms | int |
