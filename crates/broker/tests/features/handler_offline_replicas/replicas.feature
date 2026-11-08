Feature: Metadata classifies replica availability from registration fencing and directory identity
  Scenario Outline: Offline replicas retain replica order and recognize unassigned directory sentinels
    Given replicas <replicas> use directories <directories> with registrations <registrations> and unavailable brokers <unavailable>
    When the metadata response projects offline replicas for the PLAINTEXT listener
    Then the offline replica IDs in replica order are <expected>
    Examples:
      | case                                              | replicas | directories | registrations     | unavailable | expected |
      | registered directories online                     | 1,2      | good,good   | 1=good,bad;2=good | none        | none     |
      | unregistered directory                            | 1,2      | bad,good    | 1=good;2=good     | none        | 1        |
      | fenced broker                                     | 1,2      | good,good   | 1=good;2=good     | 2           | 2        |
      | unregistered broker                               | 1,2      | good,good   | 1=good            | none        | 2        |
      | unassigned directory sentinel                     | 1,2      | nil,nil     | 1=good;2=good     | none        | none     |
      | broker with no directories                        | 1,2      | bad,good    | 1=none;2=good     | none        | 1        |
      | unassigned sentinel on broker without directories | 1,2      | nil,good    | 1=none;2=good     | none        | none     |
      | replicas without directories                      | 1,2      | none        | 1=good;2=good     | none        | none     |
      | replica order kept                                | 2,1      | good,bad    | 1=good;2=good     | 2           | 2,1      |
