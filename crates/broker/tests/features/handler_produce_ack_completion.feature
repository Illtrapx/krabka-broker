Feature: Produce acks all completion reads current metadata

  Scenario Outline: Durability and current metadata decide acknowledgement
    Given an empty orders partition with ISR <isr> and durability target <target>
    And the completion metadata lookup returns <minimum>
    When acks all completes at its deadline
    Then the full Produce row has error <error> and queries the admitted topic identity once

    Examples:
      | case                      | isr   | target | minimum   | error |
      | full isr                  | 1,2,3 | 0      | 2         | 0     |
      | isr at minimum            | 1,2   | 0      | 2         | 0     |
      | isr below minimum         | 1     | 0      | 2         | 20    |
      | minimum raised            | 1,2   | 0      | 3         | 20    |
      | minimum of one            | 1     | 0      | 1         | 0     |
      | topic recreated           | 1,2,3 | 0      | recreated | 6     |
      | topic deleted             | 1,2,3 | 0      | deleted   | 3     |
      | durability target missed  | 1,2,3 | 1      | 2         | 7     |
      | deleted before durability | 1,2,3 | 1      | deleted   | 3     |
