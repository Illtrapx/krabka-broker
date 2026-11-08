Feature: ListGroups combines normalized state and type filters with authorization
  Scenario Outline: Filtering preserves complete rows and request-independent group order
    Given classic consumer share and streams groups span empty rebalancing reconciling stable and not-ready states with one denied group
    And ListGroups requests states <states> and types <types>
    When ListGroups filters the groups and applies group authorization
    Then the complete listed groups in order are <ids>
    Examples:
      | case                                 | states                      | types           | ids                                                         |
      | no filters                           | none                        | none            | classic-a,classic-b,consumer-a,consumer-b,share-a,streams-a |
      | state filter                         | empty                       | none            | classic-a,share-a                                           |
      | state filter with surrounding spaces | STABLE surrounded by spaces | none            | consumer-b                                                  |
      | several state filters                | reconciling,notready        | none            | consumer-a,streams-a                                        |
      | dead state matches nothing           | Dead                        | none            | none                                                        |
      | type filter                          | none                        | Share           | share-a                                                     |
      | several type filters                 | none                        | CLASSIC,streams | classic-a,classic-b,streams-a                               |
      | unknown type                         | none                        | unknown         | none                                                        |
      | state and type filters both apply    | empty                       | consumer        | none                                                        |
