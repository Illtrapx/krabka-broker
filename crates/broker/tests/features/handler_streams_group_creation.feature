Feature: Streams group identity and creation boundaries

  Scenario Outline: Only a join to a free group identity creates a streams group
    Given a join-ready streams broker with share group share and consumer group consumer
    When member m1 sends streams heartbeat epoch <epoch> to group <group>
    Then the streams heartbeat returns code <code>, streams group existence <exists> and message <message>

    Examples:
      | case                      | group            | epoch | code | message                                   | exists |
      | heartbeat to absent group | absent-heartbeat | 3     | 69   | Streams group absent-heartbeat not found. | false  |
      | leave from absent group   | absent-leave     | -1    | 69   | Group absent-leave not found.             | false  |
      | join a share group        | share            | 0     | 69   | Group share is not a streams group.       | false  |
      | join a consumer group     | consumer         | 0     | 69   | Group consumer is not a streams group.    | false  |
      | join creates group        | absent-join      | 0     | 0    | null                                      | true   |
