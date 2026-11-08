Feature: Verify-only transaction partition checks follow Kafka validation order

  Scenario Outline: Verify a partition against the held transaction
    Given producer 7 at epoch 3 requests transaction partition verification
    And the held transaction has producer <producer>, epoch <epoch>, state <state>, and partition membership <contains>
    When the transaction coordinator verifies the requested partition
    Then transaction partition verification returns Kafka code <code>

    Examples:
      | case                                     | producer | epoch | state          | contains | code |
      | another producer holds the transaction   | 8        | 3     | Ongoing        | true     | 49   |
      | the held epoch is newer                  | 7        | 4     | Ongoing        | true     | 90   |
      | a commit is being prepared               | 7        | 3     | PrepareCommit  | true     | 51   |
      | an abort is being prepared               | 7        | 3     | PrepareAbort   | false    | 51   |
      | the partition is in the transaction      | 7        | 3     | Ongoing        | true     | 0    |
      | the partition is not in the transaction  | 7        | 3     | Ongoing        | false    | 120  |
      | the transaction has completed            | 7        | 3     | CompleteCommit | false    | 120  |
