Feature: Bootstrap loads deprecated Kafka consumer subscription metadata
  Scenario Outline: Partition metadata creates and marks groups while tombstones clear its presence
    Given the persisted consumer partition metadata log contains <records>
    When bootstrap loads the deprecated consumer partition metadata records
    Then the consumer metadata load is <outcome> at group epoch <epoch> with persisted subscription marker <marked>
    Examples:
      | case                                    | records                                   | outcome | epoch | marked |
      | metadata alone creates a group          | metadata                                  | group   | 1     | true   |
      | metadata marks an existing group        | group-epoch-4,metadata                    | group   | 4     | true   |
      | a tombstone clears the marker           | group-epoch-4,metadata,metadata-tombstone | group   | 4     | false  |
      | a tombstone alone creates nothing       | metadata-tombstone                        | absent  | 0     | false  |
      | an unknown value version fails the load | unknown-version                           | failed  | 0     | false  |
      | truncated bytes fail the load           | truncated                                 | failed  | 0     | false  |
