Feature: JoinGroup member identifier bootstrap
  Scenario Outline: KIP-394 bootstraps only anonymous dynamic members at version four or later
    Given a JoinGroup request has member <member> and instance <instance>
    When the coordinator checks known member identity for JoinGroup version <version>
    Then the member must obtain an assigned member identifier <required>
    Examples:
      | case                                        | member | instance   | version | required |
      | an anonymous member at version four         | empty  | absent     | 4       | true     |
      | an anonymous member at version nine         | empty  | absent     | 9       | true     |
      | version three predates member id bootstrap  | empty  | absent     | 3       | false    |
      | a static member keeps its instance identity | empty  | instance-1 | 9       | false    |
      | a known member id needs no bootstrap        | m1     | absent     | 9       | false    |
