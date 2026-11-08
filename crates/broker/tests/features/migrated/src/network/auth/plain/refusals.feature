Feature: Kafka PLAIN authentication refusals
  Malformed tokens and empty fields have precise Kafka errors. Unknown users
  and wrong passwords share one error, and a refusal never authenticates a peer.

  Scenario: An empty PLAIN response reports one token
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka message Invalid SASL/PLAIN response: expected 3 tokens, got 1

  Scenario: A two-token PLAIN response reports the missing password field
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      00 61 6c 69 63 65
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka message Invalid SASL/PLAIN response: expected 3 tokens, got 2

  Scenario: A fourth PLAIN token is refused
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      00 61 6c 69 63 65 00 77 6f 6e 64 65 72 6c 61 6e 64 00 65 78 74 72 61
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka message Invalid SASL/PLAIN response: expected 3 tokens, got 4

  Scenario: Five PLAIN tokens still report the bounded four-token refusal
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      00 61 6c 69 63 65 00 77 6f 6e 64 65 72 6c 61 6e 64 00 61 00 62
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka message Invalid SASL/PLAIN response: expected 3 tokens, got 4

  Scenario: An empty authentication username is refused explicitly
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      00 00 77 6f 6e 64 65 72 6c 61 6e 64
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka message Authentication failed: username not specified

  Scenario: An empty password is refused explicitly
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      00 61 6c 69 63 65 00
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka message Authentication failed: password not specified

  Scenario: Malformed UTF-8 cannot authenticate as an unconfigured replacement-character user
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      00 ff fe 00 77 6f
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka's invalid credentials message

  Scenario: An unknown user is indistinguishable from a bad password
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      00 63 61 72 6f 6c 00 77 6f 6e 64 65 72 6c 61 6e 64
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka's invalid credentials message

  Scenario: A wrong password is indistinguishable from an unknown user
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      00 61 6c 69 63 65 00 68 75 6e 74 65 72 32
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka's invalid credentials message

  Scenario: An authorization ID naming another user is refused
    Given a PLAIN exchange is negotiating without a prior authenticated session
    And the PLAIN credential table is:
      | user  | password   |
      | alice | wonderland |
      | bob   | builder    |
    And the received PLAIN payload has these hexadecimal bytes:
      """
      62 6f 62 00 61 6c 69 63 65 00 77 6f 6e 64 65 72 6c 61 6e 64
      """
    When the broker handles PLAIN authentication without a reauthentication lifetime cap
    Then PLAIN authentication fails with Kafka message Authentication failed: Client requested an authorization id that is different from username
