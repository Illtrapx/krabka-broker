Feature: Streams topic completion caches Kafka errors until the exact expiry boundary

  Rule: Completion releases every streams topic from the in-flight set

    Scenario: A controller response releases every streams topic
      Given streams topics a, b, c and d are being created
      And the controller answered topic creation with:
        | name | code | message                     |
        | a    | 0    | null                        |
        | b    | 36   | "Topic 'b' already exists." |
        | c    | 40   | null                        |
        | d    | 38   | ""                          |
      When streams creation completes at millisecond 100 with error cache lifetime 1000 milliseconds
      Then all four streams topics leave the in-flight set

    Scenario: A controller timeout releases every streams topic
      Given streams topics a, b, c and d are being created
      And the controller topic creation request timed out
      When streams creation completes at millisecond 100 with error cache lifetime 1000 milliseconds
      Then all four streams topics leave the in-flight set

    Scenario: A refused controller envelope releases every streams topic
      Given streams topics a, b, c and d are being created
      And the controller refused the envelope with CLUSTER_AUTHORIZATION_FAILED
      When streams creation completes at millisecond 100 with error cache lifetime 1000 milliseconds
      Then all four streams topics leave the in-flight set

  Rule: Errors stay cached until the millisecond before their expiry

    Scenario: A controller response caches per-topic default and explicit messages
      Given streams topics a, b, c and d are being created
      And the controller answered topic creation with:
        | name | code | message                     |
        | a    | 0    | null                        |
        | b    | 36   | "Topic 'b' already exists." |
        | c    | 40   | null                        |
        | d    | 38   | ""                          |
      And streams creation completed at millisecond 100 with error cache lifetime 1000 milliseconds
      When streams creation errors are queried at millisecond 1099
      Then the cached streams topic errors are:
        | topic | message                                                                       |
        | b     | Topic 'b' already exists.                                                     |
        | c     | Configuration is invalid.                                                     |
        | d     | Replication factor is below 1 or larger than the number of available brokers. |

    Scenario: A controller timeout caches the timeout for every topic
      Given streams topics a, b, c and d are being created
      And the controller topic creation request timed out
      And streams creation completed at millisecond 100 with error cache lifetime 1000 milliseconds
      When streams creation errors are queried at millisecond 1099
      Then the cached streams topic errors are:
        | topic | message                                     |
        | a     | CreateTopicsRequest to controller timed out |
        | b     | CreateTopicsRequest to controller timed out |
        | c     | CreateTopicsRequest to controller timed out |
        | d     | CreateTopicsRequest to controller timed out |

    Scenario: A refused controller envelope caches the refusal for every topic
      Given streams topics a, b, c and d are being created
      And the controller refused the envelope with CLUSTER_AUTHORIZATION_FAILED
      And streams creation completed at millisecond 100 with error cache lifetime 1000 milliseconds
      When streams creation errors are queried at millisecond 1099
      Then the cached streams topic errors are:
        | topic | message                       |
        | a     | Cluster authorization failed. |
        | b     | Cluster authorization failed. |
        | c     | Cluster authorization failed. |
        | d     | Cluster authorization failed. |

  Rule: Cached errors expire exactly at their expiry

    Scenario: A controller response is no longer cached at its expiry
      Given streams topics a, b, c and d are being created
      And the controller answered topic creation with:
        | name | code | message                     |
        | a    | 0    | null                        |
        | b    | 36   | "Topic 'b' already exists." |
        | c    | 40   | null                        |
        | d    | 38   | ""                          |
      And streams creation completed at millisecond 100 with error cache lifetime 1000 milliseconds
      When streams creation errors are queried at millisecond 1100
      Then no streams topic error is cached

    Scenario: A controller timeout is no longer cached at its expiry
      Given streams topics a, b, c and d are being created
      And the controller topic creation request timed out
      And streams creation completed at millisecond 100 with error cache lifetime 1000 milliseconds
      When streams creation errors are queried at millisecond 1100
      Then no streams topic error is cached

    Scenario: A refused controller envelope is no longer cached at its expiry
      Given streams topics a, b, c and d are being created
      And the controller refused the envelope with CLUSTER_AUTHORIZATION_FAILED
      And streams creation completed at millisecond 100 with error cache lifetime 1000 milliseconds
      When streams creation errors are queried at millisecond 1100
      Then no streams topic error is cached
