Feature: Transactional commits to streams groups

  Scenario Outline: Validate transactional streams membership including a respawned actor
    Given a streams member m1 at epoch 5 and transactional commit input <input>
    When the producer transactionally commits topic a partition 0 using API version 5
    Then the complete commit response is topic a partition 0 with Kafka code <code>

    Examples:
      | case                                          | input                                                                             | code |
      | a commit without membership is accepted       | {"stopped":false,"member_id":"","group_instance_id":null,"member_epoch":-1}       | 0    |
      | a static instance without a member is unknown | {"stopped":false,"member_id":"","group_instance_id":"instance","member_epoch":-1} | 25   |
      | the current member is accepted                | {"stopped":false,"member_id":"m1","group_instance_id":null,"member_epoch":5}      | 0    |
      | a respawned actor accepts no membership       | {"stopped":true,"member_id":"","group_instance_id":null,"member_epoch":-1}        | 0    |
      | a respawned actor forgets the member          | {"stopped":true,"member_id":"m1","group_instance_id":null,"member_epoch":5}       | 25   |
