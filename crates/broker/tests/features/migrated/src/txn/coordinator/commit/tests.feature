Feature: Transaction-state append errors preserve Kafka coordinator availability semantics

  Scenario Outline: Map a failed transaction log append
    Given the transaction state log append failed with Kafka code <append>
    When the transaction coordinator maps the append failure for its client
    Then the transaction append response carries Kafka code <response>

    Examples:
      | case                                      | append | response |
      | an unknown partition means unavailable    | 3      | 15       |
      | too few replicas after append             | 20     | 15       |
      | a corrupt message passes through          | 2      | 2        |
      | too few replicas before append            | 19     | 15       |
      | a timed out append means unavailable      | 7      | 15       |
      | a lost leader means not coordinator       | 6      | 16       |
      | a storage error means not coordinator     | 56     | 16       |
      | an oversized message is unknown           | 10     | -1       |
      | an oversized record list is unknown       | 18     | -1       |
      | an unknown error stays unknown            | -1     | -1       |
