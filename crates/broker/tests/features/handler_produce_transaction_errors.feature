Feature: Transaction coordinator errors in Produce partition responses

  Scenario Outline: Translate coordinator errors at protocol compatibility boundaries
    Given a transaction coordinator answer <answer> for Produce version <version>
    When the coordinator answer becomes a Produce partition error
    Then the Produce row has code <code> and message <message>

    Examples:
      | case                                          | answer                       | version | code                        | message                                                                                                          |
      | no error                                      | NONE                         | 11      | NONE                        | null                                                                                                             |
      | fenced producer before version twelve         | PRODUCER_FENCED              | 11      | INVALID_PRODUCER_EPOCH      | null                                                                                                             |
      | invalid epoch at version twelve               | INVALID_PRODUCER_EPOCH       | 12      | INVALID_PRODUCER_EPOCH      | null                                                                                                             |
      | abortable before version eleven               | TRANSACTION_ABORTABLE        | 10      | INVALID_TXN_STATE           | Partition was not added to the transaction                                                                       |
      | abortable from version eleven                 | TRANSACTION_ABORTABLE        | 11      | TRANSACTION_ABORTABLE       | null                                                                                                             |
      | invalid transaction state                     | INVALID_TXN_STATE            | 12      | INVALID_TXN_STATE           | Partition was not added to the transaction                                                                       |
      | cluster authorization failure                 | CLUSTER_AUTHORIZATION_FAILED | 11      | INVALID_TXN_STATE           | Partition was not added to the transaction                                                                       |
      | network failure                               | NETWORK_EXCEPTION            | 12      | NOT_ENOUGH_REPLICAS         | Unable to verify the partition has been added to the transaction. Underlying error: NETWORK_EXCEPTION            |
      | coordinator moved                             | NOT_COORDINATOR              | 11      | NOT_ENOUGH_REPLICAS         | Unable to verify the partition has been added to the transaction. Underlying error: NOT_COORDINATOR              |
      | coordinator unavailable                       | COORDINATOR_NOT_AVAILABLE    | 11      | NOT_ENOUGH_REPLICAS         | Unable to verify the partition has been added to the transaction. Underlying error: COORDINATOR_NOT_AVAILABLE    |
      | coordinator loading                           | COORDINATOR_LOAD_IN_PROGRESS | 11      | NOT_ENOUGH_REPLICAS         | Unable to verify the partition has been added to the transaction. Underlying error: COORDINATOR_LOAD_IN_PROGRESS |
      | concurrent transactions before version twelve | CONCURRENT_TRANSACTIONS      | 11      | NOT_ENOUGH_REPLICAS         | Unable to verify the partition has been added to the transaction. Underlying error: CONCURRENT_TRANSACTIONS      |
      | concurrent transactions at version twelve     | CONCURRENT_TRANSACTIONS      | 12      | CONCURRENT_TRANSACTIONS     | null                                                                                                             |
      | invalid producer id mapping                   | INVALID_PRODUCER_ID_MAPPING  | 12      | INVALID_PRODUCER_ID_MAPPING | null                                                                                                             |
