@outline_feature
Feature: Examples tags per row
  Each generated case reports the tags of the block that declared its row.

  Scenario Outline: Rows report their own tags
    Then the reported tags include "<tag>" but not "<other>"

    @fast
    Examples: fast
      | tag   | other |
      | @fast | @slow |

    @slow
    Examples: slow
      | tag   | other |
      | @slow | @fast |
