Feature: AlterConfigs validates topic identity before configuration and existence after it
  Scenario Outline: The first failing topic replacement check decides the Kafka diagnostic
    Given topic orders exists and a replacement for topic <name> sets retention.ms to <retention>
    When the controller validates the authoritative topic configuration replacement
    Then topic replacement returns code <code> and message <message>
    Examples:
      | case                                 | name    | retention | code | message                                                                                                       |
      | the default topic                    | empty   | 1000      | 42   | Default topic resources are not allowed.                                                                      |
      | an illegal topic name                | a/b     | 1000      | 17   | Topic name is invalid: 'a/b' contains one or more characters other than ASCII alphanumerics, '.', '_' and '-' |
      | an absent topic                      | missing | 1000      | 3    | The topic 'missing' does not exist.                                                                           |
      | an invalid value outranks absence    | missing | abc       | 40   | Invalid value abc for configuration retention.ms: Not a number of type LONG                                   |
