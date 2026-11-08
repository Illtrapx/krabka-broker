Feature: Share persistence failures determine client codes and partition cell fencing

  Scenario Outline: Map a partition error from the share state persister
    Given the share state persister returned partition error code <persister>
    When the share partition maps the persister error and decides whether to fence its cell
    Then the client receives code <client> and partition fencing is <fenced>

    Examples:
      | case                       | persister | client | fenced |
      | a moved coordinator        | 16        | 15     | false  |
      | an unavailable coordinator | 15        | 15     | false  |
      | a loading coordinator      | 14        | 15     | false  |
      | an unknown group           | 69        | 69     | true   |
      | an unknown topic partition | 3         | 3      | true   |
      | a fenced leader epoch      | 74        | 6      | true   |
      | a fenced state epoch       | 124       | 6      | true   |
      | any other error            | 42        | -1     | false  |

  Scenario: A missing route reports an unknown server error without fencing
    Given the share state persister could not route the request with no route
    When the share partition maps the persister error and decides whether to fence its cell
    Then the client receives code -1 and partition fencing is false
