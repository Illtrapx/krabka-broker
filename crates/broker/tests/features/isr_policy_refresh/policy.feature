Feature: Fencing policy refresh releases the leader high watermark
  Scenario Outline: A scan preserves durability while refreshing follower policy
    Given a <storage> leader whose recently caught-up follower has left the ISR
    When the scan refreshes policy while respecting current durability
    Then the high watermark is <watermark>, notification is <notified> and all-acks completion is <committed>
    Examples:
      | case                                              | storage           | watermark | notified | committed |
      | a fenced follower leaves the leader alone in sync | synced            | 3         | true     | true      |
      | a diskless leader keeps its watermark             | diskless          | 0         | false    | false     |
      | a newer leader epoch supersedes the scan          | superseded        | 0         | false    | false     |
      | the follower caught-up time has expired           | expired           | 3         | true     | true      |
      | the follower is still within the lag time         | eligible          | 0         | false    | false     |
      | the ISR is below the minimum                      | below-minimum     | 0         | false    | false     |
      | a record is appended during the refresh           | concurrent-append | 4         | false    | true      |
      | the follower is due to rejoin the ISR             | pending-expansion | 0         | false    | false     |
      | the metadata ISR is not yet installed             | uninstalled-isr   | 0         | false    | false     |
