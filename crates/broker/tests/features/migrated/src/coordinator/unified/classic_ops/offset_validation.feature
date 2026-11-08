Feature: Classic offset commit membership fencing
  Scenario Outline: Kafka classic groups validate state member generation and static instance identity in order
    Given the classic group has m1 and m2 with static instance i1 pinned to m1 and state <state>
    When classic member <member> instance <instance> commits with generation <generation>
    Then the classic offset commit returns error code <code>
    Examples:
      | case                                                 | state      | member | instance | generation | code |
      | an empty group accepts an anonymous commit           | empty      | empty  | absent   | -1         | 0    |
      | an empty group accepts an unknown member             | empty      | ghost  | absent   | -1         | 0    |
      | a stable group refuses an anonymous commit           | stable     | empty  | absent   | -1         | 25   |
      | a rebalancing group refuses an anonymous commit      | preparing  | empty  | absent   | -1         | 25   |
      | an anonymous commit at the current generation        | stable     | empty  | absent   | current    | 25   |
      | an empty group refuses generation zero               | empty      | empty  | absent   | 0          | 25   |
      | an unknown member in a stable group                  | stable     | ghost  | absent   | current    | 25   |
      | a known member without a generation                  | stable     | m1     | absent   | -1         | 22   |
      | a known member at a stale generation                 | stable     | m1     | absent   | 99         | 22   |
      | a known member at the current generation             | stable     | m1     | absent   | current    | 0    |
      | a known member while the group prepares a rebalance  | preparing  | m1     | absent   | current    | 0    |
      | a known member while the group completes a rebalance | completing | m1     | absent   | current    | 27   |
      | an anonymous member claims a static instance         | stable     | empty  | i1       | current    | 82   |
      | another member claims the static instance            | stable     | m2     | i1       | current    | 82   |
      | an unknown static instance                           | stable     | m1     | i9       | current    | 25   |
      | the static instance owner commits                    | stable     | m1     | i1       | current    | 0    |
