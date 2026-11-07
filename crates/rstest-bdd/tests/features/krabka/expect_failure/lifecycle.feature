Feature: Expected failures
  Tests whose inherited tags match `expect_failure_tags` pass while a step
  fails, and fail once every step passes.

  Scenario: Finished behaviour passes normally
    Then the behaviour is finished

  @inprogress
  Scenario: Unfinished behaviour fails as expected
    Given the behaviour is started
    Then the behaviour is finished but it is not

  @inprogress
  Rule: Unfinished rule
    Scenario: Rule scenario inherits the expectation
      Then the behaviour is finished but it is not

  Rule: Mixed rows
    Scenario Outline: Outline rows expect failure per block
      Then the row is <state>

      Examples: done
        | state    |
        | finished |

      @inprogress
      Examples: pending
        | state      |
        | unfinished |

  @formulated
  Scenario: Formulated behaviour is ignored
    Then the behaviour is finished
