Feature: src coordinator unified persistence next gen assignment

  Scenario: Persist TargetAssignmentMemberValue using Kafka compacted-log schema
    Given a consumer target assignment assigns partitions 0 and 1 of the all-one topic UUID
    When the coordinator encodes this TargetAssignmentMemberValue record for the compacted group log
    Then the TargetAssignmentMemberValue record matches Kafka schema bytes including compact lengths and tagged trailers
