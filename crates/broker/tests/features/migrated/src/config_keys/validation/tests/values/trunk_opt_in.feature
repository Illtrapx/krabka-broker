Feature: Trunk topic keys require opt-in on both individual and whole-map paths
  Released mode reports the exact unknown key while unstable mode preserves canonical storage.

  Scenario Outline: Trunk topic keys require opt-in on both individual and whole-map paths
    Given a topic alteration supplies key <key> and quoted value <value>
    When the supplied key is validated individually and as a map in released and unstable modes
    Then both released and unstable modes store quoted value <canonical> exactly

    Examples:
      | case                          | key | value | canonical |
      | a padded copy lag             | remote.copy.lag.ms | " 1000 " | "1000" |
      | the copy lag sentinel         | remote.copy.lag.bytes | "-1" | "-1" |
      | the largest decompressed size | max.decompressed.message.bytes | "2147483639" | "2147483639" |
      | an uppercase dead letter flag | errors.deadletterqueue.group.enable | "TRUE" | "true" |
