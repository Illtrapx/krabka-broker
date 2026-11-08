Feature: Transaction coordinator availability follows partition replay status

  Scenario Outline: Resolve coordinator availability from load status
    Given the transaction state partition load status is <status>
    When the transaction coordinator checks whether its partition can serve requests
    Then the transaction coordinator availability error is JSON <error>

    Examples:
      | case                              | status          | error |
      | another broker leads the partition | not led locally | 16    |
      | replay has not started            | Pending         | 14    |
      | replay is running                 | Loading         | 14    |
      | replay has finished               | Loaded          | null  |
      | replay has failed                 | Failed          | 16    |
