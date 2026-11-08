Feature: Consumer current member assignments persist in the Kafka compacted-log schema

  Scenario: Persist consumer member epochs 5 and 4 hold partitions 7 and 8 at assignment epochs 3 and 5 while partition 1 awaits revocation
    Given consumer member epochs 5 and 4 hold partitions 7 and 8 at assignment epochs 3 and 5 while partition 1 awaits revocation
    When the coordinator persists and reads this current_member_assignment record
    Then the current_member_assignment bytes match Kafka exactly and decoding recovers all original record fields
