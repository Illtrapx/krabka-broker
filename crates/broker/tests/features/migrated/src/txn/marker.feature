Feature: Transaction marker response codes determine completion and retry behavior
  The coordinator follows Kafka's completion-handler policy for every relevant partition error.

  Scenario Outline: Classify marker response <error>
    Given a WriteTxnMarkers partition response has Kafka error code <code>
    When the transaction coordinator classifies the marker response
    Then the marker response decision is <decision>

    Examples:
      | case                                 | code | error                            | decision   |
      | the marker is written                | 0    | NONE                             | Written    |
      | an old message format drops it       | 43   | UNSUPPORTED_FOR_MESSAGE_FORMAT   | Dropped    |
      | an unsupported version drops it      | 35   | UNSUPPORTED_VERSION              | Dropped    |
      | an unknown partition retries         | 3    | UNKNOWN_TOPIC_OR_PARTITION       | Retriable  |
      | a lost leader retries                | 6    | NOT_LEADER_OR_FOLLOWER           | Retriable  |
      | too few replicas retries             | 19   | NOT_ENOUGH_REPLICAS              | Retriable  |
      | too few replicas after append retries | 20  | NOT_ENOUGH_REPLICAS_AFTER_APPEND | Retriable  |
      | a timeout retries                    | 7    | REQUEST_TIMED_OUT                | Retriable  |
      | a storage error retries              | 56   | KAFKA_STORAGE_ERROR              | Retriable  |
      | a stale producer epoch is fenced     | 47   | INVALID_PRODUCER_EPOCH           | Fenced     |
      | a fenced coordinator is fenced       | 52   | TRANSACTION_COORDINATOR_FENCED   | Fenced     |
      | a corrupt message is unexpected      | 2    | CORRUPT_MESSAGE                  | Unexpected |
      | an oversized message is unexpected   | 10   | MESSAGE_TOO_LARGE                | Unexpected |
      | an oversized batch is unexpected     | 18   | RECORD_LIST_TOO_LARGE            | Unexpected |
      | invalid acks are unexpected          | 21   | INVALID_REQUIRED_ACKS            | Unexpected |
      | an unknown error is unexpected       | -1   | UNKNOWN_SERVER_ERROR             | Unexpected |
      | a denied cluster is unexpected       | 31   | CLUSTER_AUTHORIZATION_FAILED     | Unexpected |
      | a moved coordinator is unexpected    | 16   | NOT_COORDINATOR                  | Unexpected |
      | a loading coordinator is unexpected  | 14   | COORDINATOR_LOAD_IN_PROGRESS     | Unexpected |
      | an invalid state is unexpected       | 48   | INVALID_TXN_STATE                | Unexpected |
