Feature: Streams member identity fences offset access

  Scenario Outline: Validate a streams offset commit
    Given streams offset identity <input> with live member m1 at epoch 5
    When the streams group validates committing in partition 0
    Then the streams offset validation returns Kafka code <code>

    Examples:
      | case                                          | input                                                                                          | code |
      | an empty group accepts anonymous commits      | {"live":false,"member_id":"","instance_id":null,"epoch":-1,"offset_commit_version":9}          | 0    |
      | a live group refuses an anonymous commit      | {"live":true,"member_id":"","instance_id":null,"epoch":-1,"offset_commit_version":9}           | 25   |
      | an anonymous commit with a member epoch       | {"live":true,"member_id":"","instance_id":null,"epoch":5,"offset_commit_version":9}            | 25   |
      | a legacy commit without a version is accepted | {"live":true,"member_id":"","instance_id":null,"epoch":-1,"offset_commit_version":null}        | 0    |
      | a static instance without a member id         | {"live":true,"member_id":"","instance_id":"instance","epoch":-1,"offset_commit_version":null}  | 25   |
      | an empty group accepts a static instance      | {"live":false,"member_id":"","instance_id":"instance","epoch":-1,"offset_commit_version":null} | 0    |
      | an unknown member id                          | {"live":true,"member_id":"m2","instance_id":null,"epoch":5,"offset_commit_version":9}          | 25   |
      | an old commit version is unsupported          | {"live":true,"member_id":"m1","instance_id":null,"epoch":5,"offset_commit_version":8}          | 35   |
      | a known member without a version              | {"live":true,"member_id":"m1","instance_id":null,"epoch":5,"offset_commit_version":null}       | 0    |
      | the current member epoch                      | {"live":true,"member_id":"m1","instance_id":null,"epoch":5,"offset_commit_version":9}          | 0    |
      | an epoch ahead of the member                  | {"live":true,"member_id":"m1","instance_id":null,"epoch":6,"offset_commit_version":9}          | 113  |
      | an epoch behind the member                    | {"live":true,"member_id":"m1","instance_id":null,"epoch":4,"offset_commit_version":9}          | 113  |

  Scenario Outline: Validate a streams offset fetch
    Given streams offset identity <input> with live member m1 at epoch 5
    When the streams group validates fetching offsets
    Then the streams offset validation returns Kafka code <code>

    Examples:
      | case                                   | input                                                                                       | code |
      | an anonymous fetch                     | {"live":true,"member_id":null,"instance_id":null,"epoch":-1,"offset_commit_version":null}   | 0    |
      | the current member epoch               | {"live":true,"member_id":"m1","instance_id":null,"epoch":5,"offset_commit_version":null}    | 0    |
      | an epoch behind the member             | {"live":true,"member_id":"m1","instance_id":null,"epoch":4,"offset_commit_version":null}    | 113  |
      | an epoch ahead of the member           | {"live":true,"member_id":"m1","instance_id":null,"epoch":6,"offset_commit_version":null}    | 113  |
      | an unknown member id                   | {"live":true,"member_id":"ghost","instance_id":null,"epoch":5,"offset_commit_version":null} | 25   |
      | an anonymous fetch with a member epoch | {"live":true,"member_id":null,"instance_id":null,"epoch":5,"offset_commit_version":null}    | 25   |
