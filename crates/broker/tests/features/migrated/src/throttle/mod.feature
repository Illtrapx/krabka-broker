Feature: Replica throttle lists accept Kafka list spellings
  Whitespace, wildcard entries and empty list segments keep Kafka's meaning.

  Scenario Outline: Whitespace selects no throttled replicas
    Given the throttled replica configuration is JSON <value>
    When the broker parses the throttled replica list
    Then the throttled replica selection is empty

    Examples:
      | case           | value |
      | a single space | " "   |

  Scenario Outline: A trimmed wildcard selects every replica
    Given the throttled replica configuration is JSON <value>
    When the broker parses the throttled replica list
    Then the throttled replica selection includes every replica

    Examples:
      | case              | value |
      | a padded wildcard | " * " |

  Scenario Outline: Explicit pairs retain order while ignoring list padding
    Given the throttled replica configuration is JSON <value>
    When the broker parses the throttled replica list
    Then the selected partition and broker pairs are JSON <pairs>

    Examples:
      | case                  | value         | pairs         |
      | padded pairs          | " 0:1 , 2:3 " | [[0,1],[2,3]] |
      | an empty list segment | "0:1,,1:2"    | [[0,1],[1,2]] |
