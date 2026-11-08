Feature: Kafka AddOffsets validation ordering

  Scenario Outline: Decide whether offsets partition 4 needs a transaction record
    Given transaction metadata and AddOffsets request <input>
    When the AddOffsets policy checks offsets partition 4
    Then the AddOffsets decision is <expected>

    Examples:
      | case                                        | input                                                                                                                                      | expected |
      | a pending producer id bump is concurrent    | {"state":"Ongoing","partitions":[],"held_id":99,"next_id":8,"requested_id":7,"requested_epoch":3,"transactional_id":"tid-offsets"}         | 51       |
      | another producer id is refused              | {"state":"Ongoing","partitions":[],"held_id":7,"next_id":-1,"requested_id":8,"requested_epoch":3,"transactional_id":"tid-offsets"}         | 49       |
      | a stale epoch is fenced                     | {"state":"Ongoing","partitions":[],"held_id":7,"next_id":-1,"requested_id":7,"requested_epoch":2,"transactional_id":"tid-offsets"}         | 90       |
      | a prepared commit is concurrent             | {"state":"PrepareCommit","partitions":[],"held_id":7,"next_id":-1,"requested_id":7,"requested_epoch":3,"transactional_id":"tid-offsets"}   | 51       |
      | a prepared abort is concurrent              | {"state":"PrepareAbort","partitions":[],"held_id":7,"next_id":-1,"requested_id":7,"requested_epoch":3,"transactional_id":"tid-offsets"}    | 51       |
      | a registered partition needs no record      | {"state":"Ongoing","partitions":[4],"held_id":7,"next_id":-1,"requested_id":7,"requested_epoch":3,"transactional_id":"tid-offsets"}        | 0        |
      | a new partition in an open transaction      | {"state":"Ongoing","partitions":[5],"held_id":7,"next_id":-1,"requested_id":7,"requested_epoch":3,"transactional_id":"tid-offsets"}        | append   |
      | an empty transaction starts                 | {"state":"Empty","partitions":[],"held_id":7,"next_id":-1,"requested_id":7,"requested_epoch":3,"transactional_id":"tid-offsets"}           | append   |
      | a completed commit starts a new transaction | {"state":"CompleteCommit","partitions":[4],"held_id":7,"next_id":-1,"requested_id":7,"requested_epoch":3,"transactional_id":"tid-offsets"} | append   |
      | a completed abort starts a new transaction  | {"state":"CompleteAbort","partitions":[],"held_id":7,"next_id":-1,"requested_id":7,"requested_epoch":3,"transactional_id":"tid-offsets"}   | append   |
