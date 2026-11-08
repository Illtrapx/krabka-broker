Feature: AlterPartition validates ISR proposals in Kafka controller order
  Scenario Outline: Non-default partition responses preserve complete success fields and default error fields
    Given partition 7 has leader 2 replicas 2,4,6 leader epoch 9 and partition epoch 11
    And broker <requester> proposes ISR <isr> at leader epoch <leader_epoch> and partition epoch <partition_epoch>
    When the controller validates and stages the ISR proposal
    Then the complete partition 7 ISR response has code <code> and exactly the matching staged change count
    Examples:
      | case                                                | requester | isr   | leader_epoch | partition_epoch | code |
      | leader epoch ahead of the controller                | 2         | 2,4   | 10           | 11              | 41   |
      | partition epoch ahead of the controller             | 2         | 2,4   | 9            | 12              | 41   |
      | partition epoch ahead outranks a stale leader epoch | 2         | 2,4   | 8            | 12              | 41   |
      | a stale leader epoch                                | 2         | 2,4   | 8            | 11              | 74   |
      | a stale leader epoch from a follower                | 4         | 2,4   | 8            | 11              | 74   |
      | a proposal from a follower                          | 4         | 2,4   | 9            | 11              | 42   |
      | a stale partition epoch                             | 2         | 2,4   | 9            | 10              | 95   |
      | stale partition epoch outranks the ISR shape        | 2         | 4,4   | 9            | 10              | 95   |
      | a duplicate ISR member                              | 2         | 2,4,4 | 9            | 11              | 42   |
      | an ISR member outside the replicas                  | 2         | 2,5   | 9            | 11              | 42   |
      | an ISR without the leader                           | 2         | 4,6   | 9            | 11              | 42   |
      | an empty ISR                                        | 2         | empty | 9            | 11              | 42   |
      | a valid shrink                                      | 2         | 2,4   | 9            | 11              | 0    |

  Scenario Outline: Controller epoch checks precede sender and ISR shape checks
    Given partition 0 has leader 1 replicas 1,2,3 ISR 1,2 leader epoch 5 and partition epoch 10
    And broker <requester> proposes ISR <isr> at leader epoch <leader_epoch> and partition epoch <partition_epoch>
    When the controller validates and stages the ISR proposal
    Then the ISR response code is <code> and a metadata change is staged only on success
    Examples:
      | case                                                | requester | isr   | leader_epoch | partition_epoch | code |
      | a valid shrink to the leader                        | 1         | 1     | 5            | 10              | 0    |
      | leader epoch ahead of the controller                | 1         | 1     | 6            | 10              | 41   |
      | partition epoch ahead outranks a stale leader epoch | 1         | 1     | 4            | 11              | 41   |
      | stale leader epoch outranks the sender check        | 2         | 1     | 4            | 9               | 74   |
      | a follower sender outranks a stale partition epoch  | 2         | 1     | 5            | 9               | 42   |
      | stale partition epoch outranks the ISR shape        | 1         | 1,4   | 5            | 9               | 95   |
      | an ISR without the leader                           | 1         | 2     | 5            | 10              | 42   |
      | a duplicate ISR member                              | 1         | 1,2,2 | 5            | 10              | 42   |

  Scenario: A fenced epoch returns only the partition index and error
    Given partition 7 has leader 2 replicas 2,4,6 leader epoch 9 and partition epoch 11
    And broker 2 proposes ISR 2,4 at leader epoch 8 and partition epoch 11
    When the controller validates and stages the ISR proposal
    Then the complete partition 7 ISR response has code 74 and exactly the matching staged change count
