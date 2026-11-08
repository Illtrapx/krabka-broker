Feature: Kafka maximum record-batch configuration domain
  A topic accepts a whole nonnegative 32-bit batch limit, including zero,
  and rejects negative, oversized, missing, and nonnumeric values.

  Scenario Outline: The maximum batch size is a nonnegative Kafka INT
    Given the quoted max.message.bytes override is <value>
    When the topic max.message.bytes override is validated
    Then the max.message.bytes override is accepted <accepted>

    Examples:
      | case               | value        | accepted |
      | zero               | "0"          | true     |
      | the default        | "1048588"    | true     |
      | the largest int    | "2147483647" | true     |
      | a negative size    | "-1"         | false    |
      | past the int range | "2147483648" | false    |
      | not a number       | "abc"        | false    |
      | an empty value     | ""           | false    |
