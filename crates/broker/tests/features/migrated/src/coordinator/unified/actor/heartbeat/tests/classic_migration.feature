Feature: Consumer heartbeats migrate classic groups

  Scenario: An offset-only classic group upgrades even with migration disabled
    Given classic group g at generation 1 has 0 members subscribed to one-partition topic t with protocol absent and migration policy disabled
    When native consumer native heartbeats at epoch 0 subscribed to t with rebalance timeout 60000 ms and no owned partitions
    Then the consumer admission error and classic metadata tombstone are
      """
      {"error_code": 0, "error_message": null, "classic_tombstone": true}
      """

  Scenario: An empty connect group is replaced by a consumer group
    Given classic group g at generation 1 has 0 members subscribed to one-partition topic t with protocol connect and migration policy bidirectional
    When native consumer native heartbeats at epoch 0 subscribed to t with rebalance timeout 60000 ms and no owned partitions
    Then the consumer admission error and classic metadata tombstone are
      """
      {"error_code": 0, "error_message": null, "classic_tombstone": true}
      """

  Scenario: A live classic group refuses a consumer join when online upgrade is disabled
    Given classic group g at generation 1 has 1 members subscribed to one-partition topic t with protocol consumer and migration policy disabled
    When native consumer native heartbeats at epoch 0 subscribed to t with rebalance timeout 60000 ms and no owned partitions
    Then the consumer admission error and classic metadata tombstone are
      """
      {"error_code": 69, "error_message": "Cannot upgrade classic group g to consumer group because online upgrade is disabled.", "classic_tombstone": false}
      """

  Scenario: A live classic group upgrades when online upgrade is allowed
    Given classic group g at generation 1 has 1 members subscribed to one-partition topic t with protocol consumer and migration policy upgrade
    When native consumer native heartbeats at epoch 0 subscribed to t with rebalance timeout 60000 ms and no owned partitions
    Then the consumer admission error and classic metadata tombstone are
      """
      {"error_code": 0, "error_message": null, "classic_tombstone": true}
      """

  Scenario: A steady heartbeat cannot create a consumer group over an offset-only group
    Given classic group g at generation 1 has 0 members subscribed to one-partition topic t with protocol absent and migration policy bidirectional
    When native consumer native heartbeats at epoch 3 subscribed to t with rebalance timeout 60000 ms and no owned partitions
    Then the consumer admission error and classic metadata tombstone are
      """
      {"error_code": 69, "error_message": "Group g is not a consumer group.", "classic_tombstone": false}
      """
