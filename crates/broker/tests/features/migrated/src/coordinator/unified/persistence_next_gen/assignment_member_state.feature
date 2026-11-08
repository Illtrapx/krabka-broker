Feature: Consumer member states keep their Kafka discriminants

  Scenario Outline: Kafka consumer member states decode and retain their discriminants
    Given a consumer member state is stored with discriminant <code>
    When the coordinator decodes the Kafka consumer member state
    Then the consumer state is <state> and its wire discriminant is preserved
    Examples:
      | case                    | code | state      |
      | a stable member         | 0    | stable     |
      | revocation is pending   | 1    | unrevoked  |
      | a release is pending    | 2    | unreleased |
      | the member was rejected | 3    | rejected   |
