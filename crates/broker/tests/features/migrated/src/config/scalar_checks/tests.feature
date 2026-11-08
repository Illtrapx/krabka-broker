Feature: Startup expiry durations fit Kafka integer milliseconds
  Embedded callers bypass file validation, so startup must reject durations
  that cannot be reported faithfully through Kafka configuration APIs.

  Scenario Outline: Reject <setting> at <amount> <unit>
    Given transaction expiry setting <setting> is <amount> <unit>
    When the in-process broker configuration is validated before startup
    Then startup refuses an invalid runtime configuration with <message>

    Examples:
      | case                                      | setting | amount | unit | message |
      | a zero expiry                             | txn_id_expiration | 0 | milliseconds | txn_id_expiration must be within 1ms..=2147483647ms |
      | an expiry past the int range              | txn_id_expiration | 2147483648 | milliseconds | txn_id_expiration must be within 1ms..=2147483647ms |
      | a fractional millisecond expiry           | txn_id_expiration | 1500000 | nanoseconds | txn_id_expiration must be a whole number of milliseconds |
      | a cleanup interval past the int range     | txn_id_expiration_cleanup_interval | 2147483648 | milliseconds | txn_id_expiration_cleanup_interval must be within 0ms..=2147483647ms |
      | a fractional millisecond cleanup interval | txn_id_expiration_cleanup_interval | 1500000 | nanoseconds | txn_id_expiration_cleanup_interval must be a whole number of milliseconds |
      | a negative cleanup interval               | txn_id_expiration_cleanup_interval | -1 | milliseconds | txn_id_expiration_cleanup_interval must be within 0ms..=2147483647ms |
