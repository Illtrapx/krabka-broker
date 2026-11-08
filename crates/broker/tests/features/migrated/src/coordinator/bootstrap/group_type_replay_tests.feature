Feature: Bootstrap holds one coordinator group type per identifier
  Scenario Outline: Persisted record order controls group replacement and conflicting type failures
    Given the coordinator log contains group g records <records>
    When bootstrap replays the records under the single group identifier
    Then group g holds <kind> with load error <message>
    Examples:
      | case                                                      | records                            | kind     | message                         |
      | offsets alone make a classic group                        | offset                             | classic  | none                            |
      | a consumer record upgrades an offset-only group           | offset,consumer                    | consumer | none                            |
      | a consumer record conflicts with a classic group          | classic,consumer                   | failed   | Group g is not a consumer group |
      | a classic tombstone frees the id for a consumer group     | classic,classic-tombstone,consumer | consumer | none                            |
      | a share record conflicts with an offset-only group        | offset,share                       | failed   | Group g is not a share group.   |
      | a share record conflicts with a consumer group            | consumer,share                     | failed   | Group g is not a share group.   |
      | a classic record replaces a consumer group                | consumer,classic                   | classic  | none                            |
      | a classic tombstone after a consumer group leaves nothing | consumer,classic-tombstone         | nothing  | none                            |
