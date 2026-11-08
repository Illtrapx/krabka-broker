Feature: Kafka replica placement counts fenced brokers but requires an unfenced leader
  Fenced replicas can satisfy replication capacity while a cluster with no
  eligible leader receives Kafka's availability refusal first.

  Scenario: Fenced replicas count toward the requested replication factor
    Given registered broker ids and fenced flags are JSON [[1,false],[2,true],[3,true]]
    When the Kafka placer assigns two partitions at replication factor 3 with seed 0
    Then the placer returns replica assignments

  Scenario Outline: Refuse an impossible placement in Kafka's validation order
    Given registered broker ids and fenced flags are JSON <brokers>
    When the Kafka placer assigns two partitions at replication factor <replication> with seed 0
    Then the placer returns no assignments and refuses with <reason>

    Examples:
      | case                                               | brokers                       | replication | reason                                                                                                                                                |
      | too few brokers for the replication factor         | [[1,false],[2,true],[3,true]] | 4           | The target replication factor of 4 cannot be reached because only 3 broker(s) are registered or some brokers have all their log directories cordoned. |
      | every broker fenced                                | [[1,true],[2,true]]           | 1           | All brokers are currently fenced, or have all their log directories cordoned.                                                                         |
      | every broker fenced at a larger replication factor | [[1,true],[2,true]]           | 3           | All brokers are currently fenced, or have all their log directories cordoned.                                                                         |
      | no registered brokers                              | []                            | 1           | All brokers are currently fenced, or have all their log directories cordoned.                                                                         |
