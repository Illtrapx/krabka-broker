Feature: External broker feature compatibility and log directory identity

  Scenario Outline: Finalized feature levels constrain broker registration
    Given the cluster has finalized metadata.version 25 and group.version 1
    And the registering broker advertises feature ranges <ranges>
    When registration checks feature compatibility with finalized levels
    Then registration validation returns error code <code>

    Examples:
      | case                               | ranges                                                    | code |
      | ranges cover the finalized levels  | metadata.version:7:25;group.version:0:1                   | 0    |
      | metadata.version below finalized   | metadata.version:7:24;group.version:0:1                   | 35   |
      | share.version above finalized zero | metadata.version:7:25;group.version:0:1;share.version:1:1 | 35   |
      | share.version range includes zero  | metadata.version:7:25;group.version:0:1;share.version:0:1 | 0    |
      | metadata.version missing           | group.version:0:1                                         | 119  |
      | no features advertised             | none                                                      | 119  |
      | group.version missing              | metadata.version:7:25                                     | 35   |
      | group.version above finalized      | group.version:2:3                                         | 35   |

  Scenario Outline: Directory IDs must be fresh or already owned by this broker
    Given broker 1 owns directory 500 and broker 2 owns directory 600 at epoch 10
    And broker 2 requests directory IDs <directories>
    When registration checks directory ownership and reserved IDs
    Then registration validation returns error code <code>

    Examples:
      | case                                | directories | code |
      | one fresh directory                 | 1000        | 0    |
      | two fresh directories               | 1000,1001   | 0    |
      | no directories                      | none        | 119  |
      | the lowest reserved id              | 0           | 119  |
      | the highest reserved id             | 99          | 119  |
      | the first unreserved id             | 100         | 0    |
      | a repeated directory                | 1000,1000   | 119  |
      | a directory another broker owns     | 1000,500    | 119  |
      | a directory the broker already owns | 600         | 0    |
