Feature: Fetch and ListOffsets preserve Kafka leader epoch fencing semantics
  Both APIs fence old epochs and reject future epochs. Fetch also accepts
  negative epochs beyond the no-epoch sentinel that ListOffsets recognizes.

  Scenario Outline: Each API applies Kafka's leader epoch sentinel rule
    Given a local partition is led at epoch 3
    When Fetch and ListOffsets request current leader epoch <epoch>
    Then Fetch is <fetch> and ListOffsets is <list_offsets> against live epoch 3

    Examples:
      | case                         | epoch       | fetch   | list_offsets |
      | an older epoch               | 2           | fenced  | fenced       |
      | the live epoch               | 3           | allowed | allowed      |
      | a future epoch               | 4           | unknown | unknown      |
      | the shared no-epoch sentinel | -1          | allowed | allowed      |
      | an epoch below the sentinel  | -2          | allowed | fenced       |
      | the most negative epoch      | -2147483648 | allowed | fenced       |
