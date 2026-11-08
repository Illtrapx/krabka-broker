Feature: Streams subscriptions include source and repartition source topics

  Scenario Outline: Project the full subscribed topic set
    Given streams group membership and source/repartition topology <input>
    When OffsetDelete asks which topics the streams group subscribes to
    Then the complete subscribed topic set is <topics>

    Examples:
      | case                                                     | input                                                                      | topics               |
      | an empty group subscribes to nothing                     | {"live":false,"topology":[["0","in",[],["rep"]],["1","other",["rep"],[]]]} | []                   |
      | a live group without a topology                          | {"live":true,"topology":null}                                              | []                   |
      | a live group subscribes to source and repartition topics | {"live":true,"topology":[["0","in",[],["rep"]],["1","other",["rep"],[]]]}  | ["in","other","rep"] |
