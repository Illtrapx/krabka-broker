Feature: Consumer group state epochs and offset commit fencing
  Scenario Outline: Group state reflects membership target epoch and reconciliation
    Given a consumer group at epoch <epoch> target epoch <target> has member epoch <member_epoch> in state <member_state>
    When the coordinator describes the consumer group state
    Then the consumer group state is <state>
    Examples:
      | case                                     | epoch | target | member_epoch | member_state | state       |
      | no members                               | 3     | 3      | absent       | stable       | Empty       |
      | no members while a new target is pending | 4     | 3      | absent       | stable       | Empty       |
      | the group epoch is ahead of the target   | 4     | 3      | 3            | stable       | Assigning   |
      | a member behind the target               | 3     | 3      | 2            | stable       | Reconciling |
      | a member waiting to release partitions   | 3     | 3      | 3            | unreleased   | Reconciling |
      | every member at the target               | 3     | 3      | 3            | stable       | Stable      |
  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (1: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 5 using offset-v9 for partitions 0,1,3
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (2: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 6 using offset-v9 for partitions 0
    Then the offset commit returns Kafka error code 113

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (3: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 4 using offset-v9 for partitions 0
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (4: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 4 using offset-v9 for partitions 2
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (5: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 3 using offset-v9 for partitions 0
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (6: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 4 using offset-v9 for partitions 1
    Then the offset commit returns Kafka error code 113

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (7: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 4 using offset-v9 for partitions 3
    Then the offset commit returns Kafka error code 113

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (8: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 4 using offset-v9 for partitions 0,1
    Then the offset commit returns Kafka error code 113

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (9: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 4 using offset-v9 for partitions none
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (10: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 5 using offset-v8 for partitions 0
    Then the offset commit returns Kafka error code 35

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (11: member classic, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member classic instance absent commits at epoch 5 using offset-v8 for partitions 0
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (12: member classic, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member classic instance absent commits at epoch 6 using offset-v9 for partitions 0
    Then the offset commit returns Kafka error code 22

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (13: member classic, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member classic instance absent commits at epoch 4 using offset-v9 for partitions 0
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (14: member classic, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member classic instance absent commits at epoch 4 using offset-v9 for partitions 1
    Then the offset commit returns Kafka error code 22

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (15: member classic, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member classic instance absent commits at epoch 4 using offset-v9 for partitions 3
    Then the offset commit returns Kafka error code 22

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (16: member empty, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member empty instance absent commits at epoch -1 using offset-v9 for partitions 0
    Then the offset commit returns Kafka error code 25

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (17: member ghost, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member ghost instance absent commits at epoch 5 using offset-v9 for partitions 0
    Then the offset commit returns Kafka error code 25

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (18: member empty, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member empty instance absent commits at epoch -1 using transactional for partitions 0
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (19: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 5 using transactional for partitions 0
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (20: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 4 using transactional for partitions 0
    Then the offset commit returns Kafka error code 0

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (21: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 4 using transactional for partitions 1
    Then the offset commit returns Kafka error code 113

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (22: member native, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member native instance absent commits at epoch 6 using transactional for partitions 0
    Then the offset commit returns Kafka error code 113

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (23: member classic, instance absent)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member classic instance absent commits at epoch 4 using transactional for partitions 3
    Then the offset commit returns Kafka error code 22

  Scenario: Offset commits enforce member generation and per-partition assignment epoch fences (24: member empty, instance i1)
    Given native and classic members at epoch 5 own partition 0 since epoch 3 partition 1 since epoch 5 and revoke partition 2 since epoch 2
    When member empty instance i1 commits at epoch -1 using transactional for partitions 0
    Then the offset commit returns Kafka error code 25

  Scenario: A joining member takes the target epoch for each new partition
    Given consumer member m1 subscribes to topic t before any assignment
    When target epoch 1 assigns partitions 0,1 and m1 reports owned partitions none joining true
    Then the partition assignment epochs are 0:1,1:1

  Scenario: A partition pending revocation keeps its assignment epoch
    Given consumer member m1 subscribes to topic t before any assignment
    And m1 has already reconciled through these heartbeats
      | target epoch | target | owned | joining |
      | 1            | 0,1    | none  | true    |
    When target epoch 2 assigns partitions 0 and m1 reports owned partitions 0,1 joining false
    Then the partition assignment epochs are 0:1,1:1

  Scenario: A revoked partition loses its assignment epoch
    Given consumer member m1 subscribes to topic t before any assignment
    And m1 has already reconciled through these heartbeats
      | target epoch | target | owned | joining |
      | 1            | 0,1    | none  | true    |
      | 2            | 0      | 0,1   | false   |
    When m1 reports revoking partition 1 while retaining partition 0
    Then the partition assignment epochs are 0:1

  Scenario: A newly assigned partition takes the new target epoch while a retained one keeps its epoch
    Given consumer member m1 subscribes to topic t before any assignment
    And m1 has already reconciled through these heartbeats
      | target epoch | target | owned | joining |
      | 1            | 0,1    | none  | true    |
      | 2            | 0      | 0,1   | false   |
      | -            | -      | 0     | false   |
    When target epoch 3 assigns partitions 0,2 and m1 reports owned partitions 0 joining false
    Then the partition assignment epochs are 0:1,2:3

  Scenario: A static leave resets every assignment epoch
    Given consumer member m1 subscribes to topic t before any assignment
    And m1 has already reconciled through these heartbeats
      | target epoch | target | owned | joining |
      | 1            | 0,1    | none  | true    |
      | 2            | 0      | 0,1   | false   |
      | -            | -      | 0     | false   |
      | 3            | 0,2    | 0     | false   |
    When m1 temporarily leaves as a static member
    Then the partition assignment epochs are 0:0,2:0
