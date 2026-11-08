Feature: TxnOffsetCommit verification errors remain compatible with Kafka request versions

  Scenario Outline: Translate a transaction coordinator answer for the client
    Given TxnOffsetCommit version <version> received transaction coordinator code <coordinator>
    When the broker maps verification for the TxnOffsetCommit response
    Then the TxnOffsetCommit response verification code is <response>

    Examples:
      | case                                          | coordinator | version | response |
      | success on an old version                     | 0           | 3       | 0        |
      | success on version five                       | 0           | 5       | 0        |
      | a fenced producer on an old version           | 90          | 3       | 47       |
      | a fenced producer on version five             | 90          | 5       | 47       |
      | an unknown producer id passes through         | 49          | 3       | 49       |
      | concurrent transactions pass through          | 51          | 5       | 51       |
      | an unexpected error becomes an invalid state  | 31          | 5       | 48       |
      | abortable before version four is invalid      | 120         | 3       | 48       |
      | abortable from version four passes through    | 120         | 4       | 120      |
      | abortable on version five passes through      | 120         | 5       | 120      |
      | a network error means loading                 | 13          | 5       | 14       |
      | an unknown partition means unavailable        | 3           | 5       | 15       |
      | an unavailable coordinator passes through     | 15          | 5       | 15       |
      | a lost leader means not coordinator           | 6           | 5       | 16       |
