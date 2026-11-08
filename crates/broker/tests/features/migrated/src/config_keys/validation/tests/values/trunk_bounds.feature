Feature: Trunk topic keys retain Kafka value validation after opt-in
  Opt-in enables names, not invalid lags, batch sizes, or boolean encodings.

  Scenario Outline: Trunk topic keys retain Kafka value validation after opt-in
    Given a topic alteration supplies key <key> and quoted value <value>
    When the supplied trunk topic value is canonicalized with unstable APIs enabled
    Then the trunk topic value is rejected by its validator

    Examples:
      | case                                   | key | value |
      | a copy lag below the sentinel          | remote.copy.lag.ms | "-2" |
      | a copy lag in bytes below the sentinel | remote.copy.lag.bytes | "-2" |
      | a zero decompressed size               | max.decompressed.message.bytes | "0" |
      | a decompressed size above its range    | max.decompressed.message.bytes | "2147483640" |
      | a non-boolean dead letter flag         | errors.deadletterqueue.group.enable | "yes" |
