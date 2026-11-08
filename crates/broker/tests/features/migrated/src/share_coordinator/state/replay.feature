Feature: Share snapshot and update replay
  Replaying a snapshot then an update retains snapshot metadata and fencing,
  advances update bookkeeping, drops old offsets, and coalesces adjacent batches.

  Scenario: An update advances a replayed snapshot without losing metadata
    Given a replay snapshot has these fields:
      | field           | value |
      | record offset   | 7     |
      | snapshot epoch  | 1     |
      | state epoch     | 2     |
      | leader epoch    | 3     |
      | start offset    | 0     |
      | completed count | 0     |
      | creation time   | 10    |
      | write time      | 20    |
    And the replay update has snapshot epoch 1, leader epoch 4, start offset 20, and completed count 7
    And the replayed records carry these delivery ranges:
      | record   | first | last | delivery  | attempts |
      | snapshot | 0     | 9    | available | 1        |
      | snapshot | 10    | 19   | available | 1        |
      | snapshot | 20    | 29   | available | 1        |
      | update   | 30    | 39   | available | 1        |
    When the coordinator replays the snapshot followed by the update
    Then the complete replayed share state is:
      | field                     | value                     |
      | state_epoch               | 2                         |
      | leader_epoch              | 4                         |
      | start_offset              | 20                        |
      | delivery_complete_count   | 7                         |
      | state_batches             | [[20,39,"available",1]]   |
      | snapshot_epoch            | 1                         |
      | create_timestamp          | 10                        |
      | write_timestamp           | 20                        |
      | last_snapshot_offset      | 7                         |
      | updates_since_snapshot    | 1                         |
      | fence_leader_epoch        | 4                         |
      | fence_state_epoch         | 2                         |
