Feature: DeleteTopics response rows carry Kafka default messages
  Scenario Outline: Topic errors explain the failure while success and request-wide failures have no row message
    Given deleting topic t with UUID bytes 3 returns error <code>
    When the DeleteTopics result row is rendered
    Then the topic identity and error remain intact with message <message>
    Examples:
      | case                          | code | message                                         |
      | success                       | 0    | null                                            |
      | topic authorization failure   | 29   | Topic authorization failed.                     |
      | unknown topic name            | 3    | This server does not host this topic-partition. |
      | unknown topic id              | 100  | This server does not host this topic ID.        |
      | throttling quota exceeded     | 89   | The throttling quota has been exceeded.         |
      | request-wide controller error | 41   | null                                            |
