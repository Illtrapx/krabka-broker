Feature: Remote time retention uses Kafka's strict cleanup cutoff
  Segments expire strictly before now minus the retention window. A negative
  cutoff disables the time axis, while an unknown timestamp is still compared.

  Scenario Outline: Evaluate timestamp <timestamp> under retention window <retention>
    Given remote segment 10 covers offsets 0 through 9, has 100 bytes and maximum timestamp <timestamp>
    And remote time retention is <retention> milliseconds
    When mutable archive retention is evaluated at millisecond 10000 with only the time limit in force
    Then the remote retention eviction set contains <deleted> segments

    Examples:
      | case                                       | timestamp | retention | deleted |
      | an unknown timestamp is still compared     | -1        | 1         | 1       |
      | a timestamp before the cutoff              | 8999      | 1000      | 1       |
      | a timestamp at the cutoff                  | 9000      | 1000      | 0       |
      | a negative cutoff disables time retention  | -1        | 10001     | 0       |
      | a zero cutoff expires an unknown timestamp | -1        | 10000     | 1       |
