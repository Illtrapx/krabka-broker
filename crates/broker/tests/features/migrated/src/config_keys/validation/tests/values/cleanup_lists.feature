Feature: Kafka cleanup lists preserve order-insensitive membership and list validation
  Empty lists disable cleanup; duplicate, empty-item, and unknown members remain invalid.

  Scenario Outline: Kafka cleanup lists preserve order-insensitive membership and list validation
    Given a topic alteration supplies key cleanup.policy and quoted value <value>
    When the cleanup policy parser and topic validator read the supplied list
    Then cleanup resolves as <policy> and the validator agrees with that outcome

    Examples:
      | case                             | value | policy |
      | delete alone                     | "delete" | delete |
      | compact alone                    | "compact" | compact |
      | compact then delete              | "compact,delete" | compact-and-delete |
      | delete then compact              | "delete,compact" | compact-and-delete |
      | a space after the comma          | "compact, delete" | compact-and-delete |
      | an unknown policy                | "junk" | invalid |
      | an unknown policy beside compact | "compact,junk" | invalid |
      | a trailing comma after compact   | "compact," | invalid |
      | a trailing comma after delete    | "delete," | invalid |
      | a repeated delete                | "delete,delete" | invalid |
      | a repeated compact               | "compact, compact" | invalid |
      | an empty list                    | "" | no-cleanup |
      | a blank list                     | " " | no-cleanup |
