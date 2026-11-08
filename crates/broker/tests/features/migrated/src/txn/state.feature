Feature: Transaction status records retain Kafka state identifiers
  Persisted transaction states must recover to the same coordinator state.

  Scenario Outline: Persist and recover transaction state <state>
    Given a transaction is in state <state>
    When the transaction state is persisted and recovered through its Kafka status byte
    Then the persisted status byte is <status> and the recovered state is <state>

    Examples:
      | case                         | state          | status |
      | a fresh transaction          | Empty          | 0      |
      | an open transaction          | Ongoing        | 1      |
      | a commit being prepared      | PrepareCommit  | 2      |
      | an abort being prepared      | PrepareAbort   | 3      |
      | a completed commit           | CompleteCommit | 4      |
      | a completed abort            | CompleteAbort  | 5      |
      | an expired transaction       | Dead           | 6      |

  Scenario Outline: Unsupported transaction status <status> remains absent
    Given a transaction log record contains Kafka status byte <status>
    When the Kafka transaction status byte is recovered
    Then the status byte has no modeled transaction state

    Examples:
      | case                         | status |
      | the byte after Dead          | 7      |
      | a negative byte              | -1     |
