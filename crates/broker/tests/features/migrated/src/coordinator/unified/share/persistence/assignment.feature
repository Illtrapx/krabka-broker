Feature: src coordinator unified share persistence assignment

  Scenario: Persist a Share target assignment assigns partition 3 of the all-one topic UUID
    Given a Share target assignment assigns partition 3 of the all-one topic UUID
    When the coordinator persists the Share target member assignment in the compacted group log
    Then the persisted Share target member assignment matches Kafka schema bytes including compact lengths and tagged trailers
