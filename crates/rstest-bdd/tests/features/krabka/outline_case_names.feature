Feature: Outline case names
  Each row is named after its first column, prefixed with the name of
  its block when the block has one, and deduplicated.

  Scenario Outline: Cases are named after their rows
    Then the running case is named "<case>"

    Examples:
      | label | case           |
      | Alice | case_1_alice   |
      | alice | case_2_alice_2 |

    Examples: Edge cases
      | label | case              |
      |       | case_3_edge_cases |

    Examples:
      | label | case       |
      | 5     | case_4_v_5 |
