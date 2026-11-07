Feature: Unknown placeholders
  A placeholder that names no Examples column is kept as literal text in
  step text, docstrings, and table cells, while known ones are substituted.

  Scenario Outline: Unknown placeholders stay verbatim
    Given the text "<known> and <unknown>" is journalled
    And the docstring is journalled
      """
      <known> keeps <unknown>
      """
    And the table is journalled
      | <known> | <unknown> |

    Examples:
      | known |
      | value |
