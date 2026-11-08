Feature: Streams current member assignments persist in the Kafka compacted-log schema

  Scenario: Persist a Streams current assignment at epochs 5 and 4 has unrevoked tasks and six empty task lists
    Given a Streams current assignment at epochs 5 and 4 has unrevoked tasks and six empty task lists
    When the coordinator persists the Streams current member assignment in the compacted group log
    Then the persisted Streams current member assignment matches Kafka schema bytes including compact lengths and tagged trailers
