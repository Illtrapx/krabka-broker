Feature: Broker-wide Kafka message size limits
  The command line accepts dimensioned byte values only when they represent
  a whole number of bytes in Kafka's nonnegative signed INT domain.

  Scenario Outline: Whole-byte limits within Kafka's INT range are accepted
    Given the operator supplies message limit <value>
    When the broker parses the message limit command line
    Then the broker-wide message limit is <bytes> bytes

    Examples:
      | case                   | value       | bytes      |
      | zero bytes             | 0B          | 0          |
      | a plain byte count     | 2048B       | 2048       |
      | the signed INT maximum | 2147483647B | 2147483647 |
      | a binary unit          | 1MiB        | 1048576    |

  Scenario Outline: Limits outside Kafka's whole-byte INT domain prevent startup
    Given the operator supplies message limit <value>
    When the broker parses the message limit command line
    Then the invalid message limit is rejected

    Examples:
      | case                      | value       |
      | negative                  | -1B         |
      | above signed INT maximum  | 2147483648B |
      | unit conversion overflows | 2GiB        |
      | fractional byte           | 1.5B        |
