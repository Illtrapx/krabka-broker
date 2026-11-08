Feature: ShareFetch exposes distinct storage corruption and broker read failures
  Scenario Outline: A failed log read maps to the Kafka partition error for its cause
    Given reading share records from an online log dir fails with <failure>
    When ShareFetch settles the failed read for its partition row
    Then the ShareFetch partition error is <code> and the log dir offline state is <offline>
    Examples:
      | case                      | failure                             | code | offline |
      | log disk failure          | a log disk I/O error                | 56   | true    |
      | corrupt transaction index | a corrupt transaction index         | 2    | false   |
      | truncated record body     | a record body shorter than one byte | 2    | false   |
      | broker io error           | a broker I/O error                  | -1   | false   |
