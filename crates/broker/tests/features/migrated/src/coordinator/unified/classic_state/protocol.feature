Feature: Classic group protocol negotiation
  Scenario Outline: Joining members must share an existing protocol and protocol type
    Given the classic group is <state> with existing consumer protocol support
    When a joining member offers protocol type <kind> with preference list <names>
    Then the offered protocols are compatible <compatible>
    Examples:
      | case                                     | state  | kind     | names    | compatible |
      | an empty protocol type                   | empty  | empty    | range    | false      |
      | an empty preference list                 | empty  | consumer | none     | false      |
      | any protocol starts an empty group       | empty  | connect  | x        | true       |
      | a different protocol type than the group | stable | connect  | sticky   | false      |
      | a protocol the group does not support    | stable | consumer | range    | false      |
      | a shared protocol among others           | stable | consumer | x,sticky | true       |
