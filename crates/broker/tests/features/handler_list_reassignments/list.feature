Feature: ListPartitionReassignments exposes ongoing partitions once per requested occurrence
  Scenario Outline: Reassignment listings preserve request order occurrences and ongoing status
    Given topic t has reassigning partitions 0 and 1 and idle partition 2
    And the reassignment request filters <filter>
    When the controller lists the requested reassignments
    Then the complete reassignment listing contains ordered topic partitions <expected>
    Examples:
      | case                     | filter     | expected |
      | every topic              | all topics | t:0,1    |
      | topic with no partitions | t:none     | none     |
      | one ongoing partition    | t:1        | t:1      |
      | repeated partition       | t:1,1      | t:1,1    |
      | request order kept       | t:1,0      | t:1,0    |
      | idle partition           | t:2        | none     |
      | unknown topic            | u:0        | none     |
      | topic named twice        | t:0;t:1    | t:0;t:1  |
