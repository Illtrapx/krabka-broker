Feature: Streams group defaults and Kafka override parsing
  Scenario: No group overrides retain all Kafka GA defaults
    Given no Streams group configuration values are overridden
    When the coordinator applies Streams group overrides to its default configuration
    Then every Streams setting equals the Kafka GA default
  Scenario Outline: Rack awareness tags are trimmed and reported in order
    Given the Streams rack awareness tags setting is JSON text <value>
    When the coordinator applies Streams group overrides to its default configuration
    Then rack tags become <tags> and DescribeConfigs reports JSON text <reported>
    Examples:
      | case                | value             | tags      | reported    |
      | an empty setting    | ""                | none      | ""          |
      | a blank setting     | "  "              | none      | ""          |
      | one tag             | "zone"            | zone      | "zone"      |
      | entries are trimmed | " zone ,\\track " | zone,rack | "zone,rack" |
  Scenario Outline: Rack awareness refuses duplicate and empty entries
    Given the Streams rack awareness tags setting is JSON text <value>
    When the coordinator applies Streams group overrides to its default configuration
    Then rack awareness tags are rejected with Kafka <reason> validation message
    Examples:
      | case                          | value            | reason    |
      | a repeated tag                | "rack,zone,rack" | duplicate |
      | a repeated tag after trimming | "zone, zone"     | duplicate |
      | an empty middle entry         | "zone,,rack"     | empty     |
      | an empty trailing entry       | "zone,"          | empty     |
  Scenario Outline: Share auto offset reset accepts only Kafka supported strategies and durations
    Given the Streams Share auto offset reset setting is JSON text <value>
    When the coordinator applies Streams group overrides to its default configuration
    Then auto offset reset selects <strategy> with duration seconds <seconds> and nanoseconds <nanos>
    Examples:
      | case                                        | value                      | strategy | seconds | nanos     |
      | latest                                      | "latest"                   | latest   | 0       | 0         |
      | earliest                                    | "earliest"                 | earliest | 0       | 0         |
      | a one hour duration                         | "by_duration:PT1H"         | duration | 3600    | 0         |
      | a duration with days and fractional seconds | "by_duration:P1DT2H3M4.5S" | duration | 93784   | 500000000 |
      | a zero duration                             | "by_duration:PT0S"         | duration | 0       | 0         |
      | a negative duration                         | "by_duration:-PT1H"        | rejected | 0       | 0         |
      | a negative component                        | "by_duration:PT-1H"        | rejected | 0       | 0         |
      | a time designator without a value           | "by_duration:PT"           | rejected | 0       | 0         |
      | a period without a value                    | "by_duration:P"            | rejected | 0       | 0         |
      | an empty duration                           | "by_duration:"             | rejected | 0       | 0         |
      | a missing duration separator                | "by_duration"              | rejected | 0       | 0         |
      | a duration without the period designator    | "by_duration:1H"           | rejected | 0       | 0         |
      | an unknown unit                             | "by_duration:PT1X"         | rejected | 0       | 0         |
      | weeks are not supported                     | "by_duration:P1W"          | rejected | 0       | 0         |
      | units out of order                          | "by_duration:PT1M1H"       | rejected | 0       | 0         |
      | strategies are case sensitive               | "Earliest"                 | rejected | 0       | 0         |
      | none is not a strategy                      | "none"                     | rejected | 0       | 0         |
      | an empty strategy                           | ""                         | rejected | 0       | 0         |
