Feature: Kafka follower progress and caught-up credit
  A follower earns credit from the fetch that proves it reached a leader log
  end. A short fetch retains earlier credit, and an overshoot never invents data.

  Scenario: A first short fetch keeps the credit of the ISR installation
    Given brokers 1 and 2 are installed in the ISR at time zero
    When follower 2 fetches offset 5 at 100 milliseconds while the leader ends at 10
    Then follower 2 has log end 5, last fetch 100, leader end 10, and caught-up time 0

  Scenario Outline: A later fetch credits caught-up time without inventing progress
    Given follower 2 last fetched to log end <end> at <fetched> milliseconds while the leader ended at <leader_end>, caught up at <caught_up>
    When follower 2 fetches offset <offset> at <at> milliseconds while the leader ends at <leader_now>
    Then follower 2 has log end <new_end>, last fetch <at>, leader end <new_leader_end>, and caught-up time <new_caught_up>

    Examples:
      | case                                                | end | fetched | leader_end | caught_up | offset | at  | leader_now | new_end | new_leader_end | new_caught_up |
      | a fetch short of the previous leader end            | 5   | 100     | 10         | 0         | 9      | 200 | 20         | 9       | 20             | 0             |
      | reaching the previous leader end credits that fetch | 9   | 200     | 20         | 0         | 20     | 300 | 30         | 20      | 30             | 200           |
      | reaching the current leader end credits this fetch  | 20  | 300     | 30         | 200       | 30     | 400 | 30         | 30      | 30             | 400           |
      | falling behind keeps the earlier credit             | 30  | 400     | 30         | 400       | 25     | 500 | 40         | 25      | 40             | 400           |
      | an overshoot is clamped to the leader end           | 25  | 500     | 40         | 400       | 99     | 600 | 40         | 40      | 40             | 600           |
