Feature: Classic member expiry while JoinGroup waits
  Scenario Outline: Waiting members use Kafka session and new-member join timeout rules
    Given m1 is new <is_new> waiting in JoinGroup <waiting> with ten second session and last heartbeat age <age>
    When the coordinator expires inactive classic members with three second initial rebalance delay
    Then the expired member list is <members>
    Examples:
      | case                                         | is_new | waiting | age                         | members |
      | a waiting member is not expired              | false  | true    | 60                          | none    |
      | an idle member past its session expires      | false  | false   | 60                          | m1      |
      | a recent heartbeat keeps the member          | false  | false   | 5                           | none    |
      | a waiting new member within the join timeout | true   | true    | 60                          | none    |
      | a waiting new member past the join timeout   | true   | true    | new-member-timeout-plus-one | m1      |
