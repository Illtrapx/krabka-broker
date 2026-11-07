Feature: Example tags control skipping per row
  Scenario Outline: example tag scopes skip allowance
    Given a scenario will be skipped

    @allow_skipped
    Examples: allowed
      | case    |
      | allowed |

    Examples: disallowed
      | case       |
      | disallowed |
