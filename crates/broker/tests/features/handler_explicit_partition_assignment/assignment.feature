Feature: CreatePartitions checks manual assignments against the topic and registered brokers

  Scenario Outline: Invalid explicit replicas preserve Kafka placement diagnostics
    Given brokers 0 1 and 2 are registered and the topic replication factor is 2
    And new partitions have explicit replica lists <lists>
    When CreatePartitions validates the explicit assignments
    Then the assignment is refused as invalid replica assignment with message <message>
    Examples:
      | case                       | lists     | message                                                                                                                                               |
      | inconsistent replica count | 0,1,2     | The manual partition assignment includes a partition with 3 replica(s), but this is not consistent with previous partitions, which have 2 replica(s). |
      | a repeated broker          | 1,1       | The manual partition assignment includes the broker 1 more than once.                                                                                 |
      | an unregistered broker     | 0,9       | The manual partition assignment includes broker 9, but no such broker is registered.                                                                  |
      | a negative broker id       | 0,-1      | The manual partition assignment includes broker -1, but no such broker is registered.                                                                 |
      | an empty replica list      | 0,1;empty | The manual partition assignment includes an empty replica list.                                                                                       |
