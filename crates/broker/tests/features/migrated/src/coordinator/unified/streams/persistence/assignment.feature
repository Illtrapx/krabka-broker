Feature: src coordinator unified streams persistence assignment

  Scenario: Persist a Streams target assignment contains active task 1 in subtopology 0 with empty standby and warmup tasks
    Given a Streams target assignment contains active task 1 in subtopology 0 with empty standby and warmup tasks
    When the coordinator persists the Streams target member assignment in the compacted group log
    Then the persisted Streams target member assignment matches Kafka schema bytes including compact lengths and tagged trailers
