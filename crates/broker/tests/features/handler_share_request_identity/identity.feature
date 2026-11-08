Feature: ShareFetch and ShareAcknowledge validate request identity before opening or continuing a session
  Scenario Outline: Null group authorization and member validity are checked in Kafka order
    Given only share group readable-group grants the consumer Read permission
    And share requests name group <group> and member <member>
    When the consumer sends ShareFetch at epoch 0 followed by ShareAcknowledge at epoch 1
    Then the complete ShareFetch response has error <fetch> and ShareAcknowledge has error <acknowledge>
    Examples:
      | case                             | group          | member        | fetch | acknowledge |
      | valid identity                   | readable-group | 36 characters | 0     | 0           |
      | null group                       | null           | 36 characters | 42    | 42          |
      | null member                      | readable-group | null          | 42    | 42          |
      | empty member                     | readable-group | empty         | 42    | 42          |
      | member id too long               | readable-group | 37 characters | 42    | 42          |
      | group denied before member check | other-group    | empty         | 30    | 30          |
