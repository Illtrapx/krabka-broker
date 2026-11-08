Feature: Kafka Envelope failure codes
  A forwarding failure retains the Kafka code its own controller would return.

  Scenario Outline: Envelope failures retain their exact Kafka wire error code
    Given the Envelope failure is <failure>
    When the Envelope failure is translated to its Kafka wire code
    Then the Envelope wire error code is <code>

    Examples:
      | case                      | failure                         | code |
      | cluster authorization     | ClusterAuthorizationFailed      | 31   |
      | principal deserialization | PrincipalDeserializationFailure | 97   |
      | unsupported version       | UnsupportedVersion              | 35   |
      | invalid request           | InvalidRequest                  | 42   |
