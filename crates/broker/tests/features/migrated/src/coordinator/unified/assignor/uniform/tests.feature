Feature: Uniform assignment balances concrete subscriptions and preserves sticky ownership
  Scenario: homogeneous Kafka assignment 1 testOneMemberNoTopicSubscription
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {} |
  Scenario: homogeneous Kafka assignment 2 testOneMemberSubscribedToNonexistentTopic
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [2] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {} |
  Scenario: homogeneous Kafka assignment 3 testFirstAssignmentTwoMembersTwoTopicsNoMemberRacks
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [2,1] | {} |
      | B | absent | [2,1] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 2 | {} |
      | 2 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1]} |
      | B | {"2":[0,1,2]} |
  Scenario: homogeneous Kafka assignment 4 testFirstAssignmentNumMembersGreaterThanTotalNumPartitions
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1] | {} |
      | B | absent | [1] | {} |
      | C | absent | [1] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 2 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {} |
      | B | {"1":[0]} |
      | C | {"1":[1]} |
  Scenario: homogeneous Kafka assignment 5 testReassignmentForTwoMembersTwoTopicsGivenUnbalancedPrevAssignment
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,2] | {"1":[0,1],"2":[0,1]} |
      | B | absent | [1,2] | {"1":[2],"2":[2]} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
      | 2 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1],"2":[0]} |
      | B | {"1":[2],"2":[1,2]} |
  Scenario: homogeneous Kafka assignment 6 testReassignmentWhenPartitionsAreAddedForTwoMembersTwoTopics
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [2,1] | {"1":[0],"2":[0,2]} |
      | B | absent | [2,1] | {"1":[1,2],"2":[1]} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 5 | {} |
      | 2 | 6 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,3,4],"2":[0,2]} |
      | B | {"1":[1,2],"2":[1,3,4,5]} |
  Scenario: homogeneous Kafka assignment 7 testReassignmentWhenOneMemberAddedAfterInitialAssignmentWithTwoMembersTwoTopics
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,2] | {"1":[0,2],"2":[0]} |
      | B | absent | [1,2] | {"1":[1],"2":[1,2]} |
      | C | absent | [1,2] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
      | 2 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,2]} |
      | B | {"1":[1],"2":[1]} |
      | C | {"2":[0,2]} |
  Scenario: homogeneous Kafka assignment 8 testReassignmentWhenOneMemberRemovedAfterInitialAssignmentWithThreeMembersTwoTopics
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [2,1] | {"1":[0],"2":[0]} |
      | B | absent | [2,1] | {"1":[1],"2":[1]} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
      | 2 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,2],"2":[0]} |
      | B | {"1":[1],"2":[1,2]} |
  Scenario: homogeneous Kafka assignment 9 testReassignmentWhenOneSubscriptionRemovedAfterInitialAssignmentWithTwoMembersTwoTopics
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [2] | {"1":[0],"2":[0]} |
      | B | absent | [2] | {"1":[1],"2":[1]} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 2 | {} |
      | 2 | 2 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"2":[0]} |
      | B | {"2":[1]} |
  Scenario: heterogeneous Kafka assignment 10 testTwoMembersNoTopicSubscription
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [] | {} |
      | B | absent | [] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {} |
      | B | {} |
  Scenario: heterogeneous Kafka assignment 11 testTwoMembersSubscribedToNonexistentTopics
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [3] | {} |
      | B | absent | [2] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {} |
      | B | {} |
  Scenario: heterogeneous Kafka assignment 12 testFirstAssignmentTwoMembersTwoTopics
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,3] | {} |
      | B | absent | [3] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
      | 3 | 6 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1,2],"3":[4]} |
      | B | {"3":[0,1,2,3,5]} |
  Scenario: heterogeneous Kafka assignment 13 testFirstAssignmentNumMembersGreaterThanTotalNumPartitions
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [3] | {} |
      | B | absent | [3] | {} |
      | C | absent | [1] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 2 | {} |
      | 3 | 1 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"3":[0]} |
      | B | {} |
      | C | {"1":[0,1]} |
  Scenario: heterogeneous Kafka assignment 14 testReassignmentForTwoMembersThreeTopicsGivenUnbalancedPrevAssignment
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1] | {"1":[0,1,2]} |
      | B | absent | [1,2] | {"1":[3],"2":[0]} |
      | C | absent | [1,2,3] | {"1":[4,5],"2":[1,2,3],"3":[0,1,2,3]} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 6 | {} |
      | 2 | 4 | {} |
      | 3 | 4 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1,2,5]} |
      | B | {"1":[3],"2":[0,1,2,3]} |
      | C | {"1":[4],"3":[0,1,2,3]} |
  Scenario: heterogeneous Kafka assignment 15 testReassignmentWhenPartitionsAreAddedForTwoMembers
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,3] | {"1":[0,1,2,3],"3":[0,1]} |
      | B | absent | [1,2,3,4] | {"2":[0,1,2],"4":[0,1,2]} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 6 | {} |
      | 2 | 5 | {} |
      | 3 | 3 | {} |
      | 4 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1,2,3,4,5],"3":[0,1,2]} |
      | B | {"2":[0,1,2,3,4],"4":[0,1,2]} |
  Scenario: heterogeneous Kafka assignment 16 testReassignmentWhenOneMemberAddedAndPartitionsAddedTwoMembersTwoTopics
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1] | {"1":[0,2],"2":[0]} |
      | B | absent | [1,2] | {"1":[1],"2":[1,2]} |
      | C | absent | [1,2] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 6 | {} |
      | 2 | 7 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,2,3,4,5]} |
      | B | {"1":[1],"2":[1,2,6]} |
      | C | {"2":[0,3,4,5]} |
  Scenario: heterogeneous Kafka assignment 17 testReassignmentWhenOneMemberRemovedAfterInitialAssignmentWithThreeMembersThreeTopics
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,3] | {"1":[0,1,2],"3":[0,1]} |
      | B | absent | [2] | {"2":[3,4,5,6]} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
      | 2 | 8 | {} |
      | 3 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1,2],"3":[0,1,2]} |
      | B | {"2":[0,1,2,3,4,5,6,7]} |
  Scenario: heterogeneous Kafka assignment 18 testReassignmentWhenOneSubscriptionRemovedAfterInitialAssignmentWithTwoMembersTwoTopics
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1] | {"1":[0,2],"2":[1,3]} |
      | B | absent | [1,2] | {"1":[1],"2":[0,2,4]} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
      | 2 | 5 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1,2]} |
      | B | {"2":[0,1,2,3,4]} |
  Scenario: heterogeneous Kafka assignment 19 testReassignmentWhenTopicPartitionsRunOutAndMembersHaveNoPartitions
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,2,3] | {"1":[0,1],"2":[0,1],"3":[0,1]} |
      | B | absent | [1,2,3] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 2 | {} |
      | 2 | 2 | {} |
      | 3 | 2 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"2":[0],"3":[0,1]} |
      | B | {"1":[0,1],"2":[1]} |
  Scenario: heterogeneous Kafka assignment 20 testFirstAssignmentWithTwoMembersIncludingOneWithoutSubscriptions
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1] | {} |
      | B | absent | [] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 3 | {} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1,2]} |
      | B | {} |
  Scenario: homogeneous partition balance outranks replica rack affinity
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | r1 | [1] | {} |
      | B | r2 | [1] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 4 | {"0":["r1"],"1":["r1"],"2":["r1"],"3":["r1"]} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,1]} |
      | B | {"1":[2,3]} |
  Scenario: heterogeneous partition balance outranks replica rack affinity
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | r1 | [1] | {} |
      | B | r2 | [1] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 4 | {"0":["r1"],"1":["r1"],"2":["r1"],"3":["r1"]} |
    When the uniform assignor balances the subscribed partitions
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"1":[0,2]} |
      | B | {"1":[1,3]} |
  Scenario: Diverging resolved subscriptions force the heterogeneous builder
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,2] | {} |
      | B | absent | [1] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 2 | {} |
      | 2 | 2 | {} |
    When the uniform assignor balances the partitions with the declared builder and with an explicit heterogeneous builder
    Then the complete uniform assignment is
      | member | partitions |
      | A | {"2":[0,1]} |
      | B | {"1":[0,1]} |
    And the declared homogeneous and explicit heterogeneous assignments are identical
  Scenario: A large homogeneous sample has valid balanced assignments
    Given a homogeneous group has 100 three-partition topics and 49 subscribing members
    When the uniform assignor balances the subscribed partitions
    Then every subscribed partition is assigned once and member loads differ by at most one
  Scenario: homogeneous reassignment is a fixed point in every member order
    Given a homogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,2,3] | {} |
      | B | absent | [1,2,3] | {} |
      | C | absent | [1,2,3] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 2 | {} |
      | 2 | 5 | {} |
      | 3 | 7 | {} |
    When the uniform assignor reassigns from its own first assignment in all six member orders
    Then the first assignment is valid and all six reordered assignments preserve every owner
  Scenario: heterogeneous reassignment is a fixed point in every member order
    Given a heterogeneous uniform group has these member subscriptions and previous assignments
      | member | rack | subscriptions | previous |
      | A | absent | [1,2,3] | {} |
      | B | absent | [1,2,3] | {} |
      | C | absent | [1,2,3] | {} |
    And the uniform topic partitions and replica racks are
      | topic | partitions | replica_racks |
      | 1 | 2 | {} |
      | 2 | 5 | {} |
      | 3 | 7 | {} |
    When the uniform assignor reassigns from its own first assignment in all six member orders
    Then the first assignment is valid and all six reordered assignments preserve every owner
