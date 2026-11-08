Feature: Kafka super-user principal configuration
  Any Kafka principal may be a super-user, including ANONYMOUS for controller
  and inter-broker requests made over PLAINTEXT listeners.

  Scenario Outline: Startup accepts Kafka's supported super-user sets
    Given the broker super-user principals are <principals>
    When the broker startup configuration is validated for those principals
    Then the super-user set is accepted without excluding ANONYMOUS

    Examples:
      | case                          | principals                    |
      | no super-users                | []                            |
      | one named user                | ["operator"]                  |
      | only ANONYMOUS                | ["ANONYMOUS"]                 |
      | ANONYMOUS beside a named user | ["ANONYMOUS","operator"]      |
