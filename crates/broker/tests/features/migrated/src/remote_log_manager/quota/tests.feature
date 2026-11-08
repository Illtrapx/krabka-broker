Feature: Remote-log quotas follow Kafka sampled rates and retain history across updates

  Scenario: An idle quota allows an operation immediately
    Given a remote-log quota permits 1000 bytes per second with Kafka sample windows
    When the manager samples the remote-log throttle at millisecond 0
    Then the remote-log throttle is 0 milliseconds

  Scenario Outline: A burst decays to the allowed rate as the window widens
    Given a remote-log quota permits 1000 bytes per second with Kafka sample windows
    And the manager has recorded 2000 remote-log bytes at millisecond 0
    When the manager samples the remote-log throttle at millisecond <at>
    Then the remote-log throttle is <wait> milliseconds

    Examples:
      | case                      | at   | wait |
      | at the burst              | 0    | 1000 |
      | partway through the decay | 1500 | 500  |
      | once the rate has decayed | 2000 | 0    |

  Scenario Outline: A sample expires exactly at the end of the whole window
    Given a remote-log quota permits 1 bytes per second with Kafka sample windows
    And the manager has recorded 1000000 remote-log bytes at millisecond 0
    When the manager samples the remote-log throttle at millisecond <at>
    Then the remote-log throttle is <wait> milliseconds

    Examples:
      | case                           | at    | wait      |
      | one millisecond before the end | 10999 | 999989001 |
      | at the end of the whole window | 11000 | 0         |

  Scenario: Later samples add to the measured byte rate
    Given a remote-log quota permits 1000 bytes per second with Kafka sample windows
    And the manager has recorded these remote-log bytes:
      | millisecond | bytes |
      | 0           | 1000  |
      | 1000        | 1000  |
      | 2000        | 2000  |
    When the manager samples the remote-log throttle at millisecond 2000
    Then the remote-log throttle is 2000 milliseconds

  Scenario: Raising the bound releases the previously recorded burst
    Given a remote-log quota permits 1000 bytes per second with Kafka sample windows
    And the manager has recorded 2000 remote-log bytes at millisecond 0
    And the remote-log byte-rate bound has been changed to 4000
    When the manager samples the remote-log throttle at millisecond 0
    Then the remote-log throttle is 0 milliseconds

  Scenario: An unlimited bound does not throttle a burst
    Given a remote-log quota permits 9223372036854775807 bytes per second with Kafka sample windows
    And the manager has recorded 2000 remote-log bytes at millisecond 0
    When the manager samples the remote-log throttle at millisecond 0
    Then the remote-log throttle is 0 milliseconds

  Scenario: Lowering an unlimited bound throttles existing history
    Given a remote-log quota permits 9223372036854775807 bytes per second with Kafka sample windows
    And the manager has recorded 2000 remote-log bytes at millisecond 0
    And the remote-log byte-rate bound has been changed to 500
    When the manager samples the remote-log throttle at millisecond 0
    Then the remote-log throttle is 3000 milliseconds

  Scenario: An acquisition within an idle quota is admitted
    Given a remote-log quota permits 1000 bytes per second with Kafka sample windows
    When the manager tries to acquire 3000 remote-log bytes at millisecond 0
    Then the remote-log acquisition is admitted

  Scenario: An acquisition over the quota is refused for the throttle time
    Given a remote-log quota permits 1000 bytes per second with Kafka sample windows
    And the manager has acquired 3000 remote-log bytes at millisecond 0
    When the manager tries to acquire 1 remote-log bytes at millisecond 0
    Then the remote-log acquisition is refused for 2000 milliseconds

  Scenario: A refused acquisition records no bytes
    Given a remote-log quota permits 1000 bytes per second with Kafka sample windows
    And the manager has acquired 3000 remote-log bytes at millisecond 0
    And the manager has been refused 1 remote-log bytes at millisecond 0
    When the manager samples the remote-log throttle at millisecond 0
    Then the remote-log throttle is 2000 milliseconds
