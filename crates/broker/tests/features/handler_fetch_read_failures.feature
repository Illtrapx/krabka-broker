Feature: Fetch read failures and directory health

  Scenario Outline: Read exceptions produce partition errors and only disk failures fence directories
    Given an online partition log whose read fails with <failure>
    When Fetch settles the failed read for response partition 4
    Then the full Fetch refusal has code <code> and the directory offline state is <offline>

    Examples:
      | case                      | failure                          | code | offline |
      | disk failure              | IO-EIO                           | 56   | true    |
      | offset before log start   | requested-0-before-log-start-5   | 1    | false   |
      | offset before local start | requested-0-before-local-start-5 | 1    | false   |
      | corrupt batch header      | corrupt-record-batch-header      | 2    | false   |
      | unparseable batch         | record-batch-that-does-not-parse | 2    | false   |
      | read task panic           | task-panic-boom                  | -1   | false   |
