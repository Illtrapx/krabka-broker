Feature: JoinGroup request validation and response compatibility
  Scenario Outline: Default session bounds and group identity are enforced
    Given a join request for group <group> with session timeout <timeout> milliseconds
    When the join request is validated against the default session bounds
    Then join validation returns <expected>
    Examples:
      | case                  | group | timeout | expected |
      | empty group id        | empty | 10000   | 24       |
      | negative timeout      | g     | -1      | 26       |
      | below minimum timeout | g     | 5999    | 26       |
      | at minimum timeout    | g     | 6000    | accepted |
      | at maximum timeout    | g     | 1800000 | accepted |
      | above maximum timeout | g     | 1800001 | 26       |

  Scenario Outline: Empty protocol names become null only in versions that support null
    Given an authorization failure join response has protocol name <protocol>
    When the join response is encoded and decoded at every supported API version
    Then the join response preserves its error fields and uses Kafka version-specific null protocol semantics
    Examples:
      | case                | protocol |
      | empty protocol name | empty    |
      | null protocol name  | null     |
      | named protocol      | range    |
