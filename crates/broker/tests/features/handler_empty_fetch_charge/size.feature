Feature: Fetch quota accounting includes version-specific empty response overhead
  Scenario Outline: The empty response is charged according to its Kafka wire layout
    Given an empty Fetch response uses API version <version>
    When the fetch response size is charged to the consumer byte quota
    Then the empty response quota charge is <bytes> bytes
    Examples:
      | case                                        | version | bytes |
      | original layout                             | 0       | 8     |
      | throttle time added                         | 1       | 12    |
      | isolation level leaves empty size unchanged | 4       | 12    |
      | session id added                            | 7       | 18    |
      | flexible tagged layout                      | 12      | 16    |
