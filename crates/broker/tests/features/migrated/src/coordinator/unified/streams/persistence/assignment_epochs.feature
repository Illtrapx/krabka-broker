Feature: Streams current member assignment epochs persist in the Kafka compacted-log schema

  Scenario: Persist Streams active tasks 1 and 2 have epochs 4 and 5 while active task 3 awaits revocation at epoch 3
    Given Streams active tasks 1 and 2 have epochs 4 and 5 while active task 3 awaits revocation at epoch 3
    When the coordinator persists and reads this current_member_assignment_epochs record
    Then the current_member_assignment_epochs bytes match Kafka exactly and decoding recovers all original record fields
