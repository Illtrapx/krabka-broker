Feature: Share heartbeat assignments initialization leave and member epochs

  Scenario: Uninitialized Share partitions remain unassigned
    Given Share group g subscribes to four-partition topic t with initialized partitions none
    When Share member m1 heartbeats at epoch 0 including topic subscription true
    Then the complete Share response names member m1 at epoch 2 with assignment []

  Scenario: An unchanged empty Share assignment is omitted
    Given Share group g subscribes to four-partition topic t with initialized partitions none
    And these Share heartbeats have been answered in order
      | member | epoch | subscription |
      | m1     | 0     | true         |
    When Share member m1 heartbeats at epoch 2 including topic subscription false
    Then the complete Share response names member m1 at epoch 2 with assignment omitted

  Scenario: A first member takes every initialized Share partition
    Given Share group g subscribes to four-partition topic t with initialized partitions all
    When Share member m1 heartbeats at epoch 0 including topic subscription true
    Then the complete Share response names member m1 at epoch 2 with assignment [0,1,2,3]

  Scenario: An unchanged Share assignment is omitted
    Given Share group g subscribes to four-partition topic t with initialized partitions all
    And these Share heartbeats have been answered in order
      | member | epoch | subscription |
      | m1     | 0     | true         |
    When Share member m1 heartbeats at epoch 2 including topic subscription false
    Then the complete Share response names member m1 at epoch 2 with assignment omitted

  Scenario: A joining member takes half of the initialized Share partitions
    Given Share group g subscribes to four-partition topic t with initialized partitions all
    And these Share heartbeats have been answered in order
      | member | epoch | subscription |
      | m1     | 0     | true         |
      | m1     | 2     | false        |
    When Share member m2 heartbeats at epoch 0 including topic subscription true
    Then the complete Share response names member m2 at epoch 3 with assignment [0,1]

  Scenario: The first member learns its reduced Share assignment at the new epoch
    Given Share group g subscribes to four-partition topic t with initialized partitions all
    And these Share heartbeats have been answered in order
      | member | epoch | subscription |
      | m1     | 0     | true         |
      | m1     | 2     | false        |
      | m2     | 0     | true         |
    When Share member m1 heartbeats at epoch 2 including topic subscription false
    Then the complete Share response names member m1 at epoch 3 with assignment [2,3]

  Scenario: A reduced Share assignment is omitted once delivered
    Given Share group g subscribes to four-partition topic t with initialized partitions all
    And these Share heartbeats have been answered in order
      | member | epoch | subscription |
      | m1     | 0     | true         |
      | m1     | 2     | false        |
      | m2     | 0     | true         |
      | m1     | 2     | false        |
    When Share member m1 heartbeats at epoch 3 including topic subscription false
    Then the complete Share response names member m1 at epoch 3 with assignment omitted

  Scenario: A heartbeat with its subscription receives the full Share assignment again
    Given Share group g subscribes to four-partition topic t with initialized partitions all
    And these Share heartbeats have been answered in order
      | member | epoch | subscription |
      | m1     | 0     | true         |
      | m1     | 2     | false        |
      | m2     | 0     | true         |
      | m1     | 2     | false        |
      | m1     | 3     | false        |
    When Share member m1 heartbeats at epoch 3 including topic subscription true
    Then the complete Share response names member m1 at epoch 3 with assignment [2,3]

  Scenario Outline: Known and unknown Share members leave with Kafka durability rules
    Given Share group g subscribes to four-partition topic t with initialized partitions none
    And m1 has joined Share group g at epoch 2
    When Share member <member> leaves with epoch minus one
    Then the Share leave result for <member> appends <batches> batches and leaves group epoch <epoch>
    Examples:
      | case                        | member | batches | epoch |
      | a known member leaves       | m1     | 1       | 3     |
      | an unknown member cannot leave | m9  | 0       | 2     |
  Scenario Outline: Share member epoch fencing accepts only rejoin previous or current member epochs
    Given Share group g subscribes to four-partition topic t with initialized partitions none
    And m1 joined at epoch 2 then m2 and m3 joined and m1 advanced from previous epoch 2 to current epoch 4
    When Share member <member> heartbeats at epoch <epoch> including topic subscription true
    Then the epoch validation returns the complete Share <outcome> response
    Examples:
      | case                               | member | epoch | outcome        |
      | a rejoin at epoch zero             | m1     | 0     | accepted       |
      | the previous member epoch          | m1     | 2     | accepted       |
      | an epoch between previous and current | m1  | 3     | fenced         |
      | the current member epoch           | m1     | 4     | accepted       |
      | an epoch ahead of the member       | m1     | 5     | fenced         |
      | an unknown member                  | m9     | 4     | unknown-member |
