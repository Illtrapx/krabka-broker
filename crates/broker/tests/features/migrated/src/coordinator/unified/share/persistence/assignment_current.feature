Feature: Share current member assignments persist in the Kafka compacted-log schema

  Scenario: Persist ShareGroupCurrentMemberAssignmentValue using Kafka compacted-log schema
    Given a Share current assignment at epochs 5 and 4 has no assigned partitions
    When the coordinator encodes this ShareGroupCurrentMemberAssignmentValue record for the compacted group log
    Then the ShareGroupCurrentMemberAssignmentValue record matches Kafka schema bytes including compact lengths and tagged trailers
