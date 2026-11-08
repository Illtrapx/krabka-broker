Feature: DescribeClientQuotas validates entity filters before matching stored values

  Scenario Outline: Invalid filter shapes fail the complete request before matching stored quotas
    Given user alice has producer byte rate 1024 and the default user quota is 2048
    And the exact-type quota filter has components <components>
    When an admin describes quotas using that exact-type filter
    Then the complete quota description refusal has code <code> message <message> and null entries
    Examples:
      | case                        | components                              | code | message                                                                                                                     |
      | empty entity type           | empty:specified:null                    | 42   | Invalid empty entity type.                                                                                                  |
      | repeated entity type        | user:exact:alice;user:specified:null    | 42   | Entity type user cannot appear more than once in the filter.                                                                |
      | unsupported entity type     | group:specified:null                    | 35   | Unsupported entity type group                                                                                               |
      | exact match without a name  | user:exact:null                         | 42   | Request specified MATCH_TYPE_EXACT, but set match string to null.                                                           |
      | default match with a name   | user:default:alice                      | 42   | Request specified MATCH_TYPE_DEFAULT, but also specified a match string.                                                    |
      | specified match with a name | user:specified:alice                    | 42   | Request specified MATCH_TYPE_SPECIFIED, but also specified a match string.                                                  |
      | unknown match type          | user:7:null                             | 42   | Unknown match type 7                                                                                                        |
      | IP beside user              | ip:specified:null;user:specified:null   | 42   | Invalid entity filter component combination. IP filter component should not be used with user or clientId filter component. |
      | IP beside client id         | client-id:default:null;ip:exact:1.2.3.4 | 42   | Invalid entity filter component combination. IP filter component should not be used with user or clientId filter component. |

  Scenario Outline: Exact and default filters preserve complete matching quota rows
    Given user alice has producer byte rate 1024 and the default user quota is 2048
    And the exact-type quota filter has components <components>
    When an admin describes quotas using that exact-type filter
    Then the complete quota response names user <user> with producer byte rate <value>
    Examples:
      | case         | components        | user    | value |
      | exact user   | user:exact:alice  | alice   | 1024  |
      | default user | user:default:null | default | 2048  |

  Scenario: Specified-user matching includes default user entities
    Given user alice has producer byte rate 1024 and the default user quota is 2048
    And the exact-type quota filter has components user:specified:null
    When an admin describes quotas using that exact-type filter
    Then the specified-user filter matches both default and named alice entities
