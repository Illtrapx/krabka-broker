Feature: Streams member states keep their Kafka discriminants

  Scenario Outline: Logical Streams states preserve Kafka discriminants
    Given a Streams member is <state>
    When the coordinator converts the Streams state to Kafka wire state and back
    Then the Streams state retains its identity and Kafka discriminant is <code>
    Examples:
      | case                  | state      | code |
      | a stable member       | stable     | 1    |
      | revocation is pending | unrevoked  | 2    |
      | a release is pending  | unreleased | 3    |

  Scenario: Zero is not a Kafka Streams member state
    Given the stored Streams member state discriminant is 0
    When the coordinator decodes the stored Streams member state
    Then the invalid Streams state discriminant is rejected
