Feature: Ordinary transaction timeouts obey Kafka positive bounded milliseconds

  Scenario Outline: Accept a timeout within the positive configured range
    Given the maximum ordinary transaction timeout is 8000 milliseconds
    And the producer requests transaction timeout <requested> milliseconds
    When the broker resolves the non-two-phase-commit transaction timeout
    Then the configured ordinary transaction timeout is <requested> milliseconds

    Examples:
      | case                   | requested |
      | the smallest timeout   | 1         |
      | a timeout in the range | 5000      |
      | the configured maximum | 8000      |

  Scenario Outline: Refuse a timeout outside the Kafka range
    Given the maximum ordinary transaction timeout is 8000 milliseconds
    And the producer requests transaction timeout <requested> milliseconds
    When the broker resolves the non-two-phase-commit transaction timeout
    Then the transaction timeout is refused with Kafka error code 50

    Examples:
      | case                          | requested   |
      | one above the maximum         | 8001        |
      | a zero timeout                | 0           |
      | a negative timeout            | -1          |
      | the smallest int              | -2147483648 |
      | the largest int               | 2147483647  |
