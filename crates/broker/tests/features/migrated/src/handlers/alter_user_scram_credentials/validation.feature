Feature: SCRAM credential iteration ceiling
  Kafka permits 16384 iterations and rejects a count above that ceiling
  without staging any credential mutation.

  Scenario Outline: Credential upsertions respect Kafka's inclusive iteration maximum
    Given the SCRAM alteration has cluster ALTER permission
    And alice supplies a SCRAM-SHA-256 credential upsertion with <iterations> iterations
    When the controller validates the SCRAM credential upsertion
    Then alice's SCRAM alteration returns error <code> with message <message>
    And exactly <records> credential metadata records are staged

    Examples:
      | case                  | iterations | code | message               | records |
      | the inclusive maximum | 16384      | 0    | null                  | 1       |
      | one past the maximum  | 16385      | 93   | "Too many iterations" | 0       |
