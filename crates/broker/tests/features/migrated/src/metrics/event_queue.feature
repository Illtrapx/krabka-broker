Feature: Controller event queue recorders publish Kafka named series in seconds

  Scenario: Nothing recorded initializes every series to zero
    Given a fresh controller event queue metrics registry
    When the Kafka named controller queue series are scraped
    Then the controller event queue metrics contain:
      | queue_count | queue_sum | processing_count | processing_sum | started | timed_out | idle_seconds |
      | 0           | 0         | 0                | 0              | 0       | 0         | 0            |

  Scenario: Queue wait uses a seconds histogram
    Given a controller operation has waited 250 milliseconds in the queue
    When the Kafka named controller queue series are scraped
    Then the controller event queue metrics contain:
      | queue_count | queue_sum | processing_count | processing_sum | started | timed_out | idle_seconds |
      | 1           | 0.25      | 0                | 0              | 0       | 0         | 0            |

  Scenario: Processing times accumulate in seconds
    Given a controller operation has taken 500 milliseconds to process
    And a controller operation has taken 250 milliseconds to process
    When the Kafka named controller queue series are scraped
    Then the controller event queue metrics contain:
      | queue_count | queue_sum | processing_count | processing_sum | started | timed_out | idle_seconds |
      | 0           | 0         | 2                | 0.75           | 0       | 0         | 0            |

  Scenario: Started and timed out operations have independent counters
    Given a controller operation has started
    And a controller operation has started
    And a controller operation has timed out
    When the Kafka named controller queue series are scraped
    Then the controller event queue metrics contain:
      | queue_count | queue_sum | processing_count | processing_sum | started | timed_out | idle_seconds |
      | 0           | 0         | 0                | 0              | 2       | 1         | 0            |

  Scenario: Idle durations accumulate as an idle seconds counter
    Given the controller queue has been idle for 1500 milliseconds
    And the controller queue has been idle for 500 milliseconds
    When the Kafka named controller queue series are scraped
    Then the controller event queue metrics contain:
      | queue_count | queue_sum | processing_count | processing_sum | started | timed_out | idle_seconds |
      | 0           | 0         | 0                | 0              | 0       | 0         | 2            |
