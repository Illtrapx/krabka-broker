Feature: DescribeGroups exposes every classic coordinator state in Kafka vocabulary
  Scenario Outline: Coordinator transitions have distinct public state names
    Given the classic group <condition>
    When DescribeGroups renders the classic group state
    Then the reported classic group state is <expected>
    Examples:
      | case                 | condition                 | expected            |
      | empty                | has no members            | Empty               |
      | preparing rebalance  | is preparing a rebalance  | PreparingRebalance  |
      | completing rebalance | is completing a rebalance | CompletingRebalance |
      | stable               | has a stable assignment   | Stable              |
