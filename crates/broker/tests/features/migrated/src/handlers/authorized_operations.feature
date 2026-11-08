Feature: Kafka authorized-operation discovery
  Clients receive the permissions supported by each resource type and use
  Kafka's operation-code bit positions to decode authorization bitfields.

  Scenario: Topics expose exactly their supported permissions
    Given an authorization query concerns a topic resource
    When the broker lists the resource's supported permissions
    Then the supported permissions are exactly Read,Write,Create,Delete,Alter,Describe,DescribeConfigs,AlterConfigs

  Scenario: Groups expose exactly their supported permissions
    Given an authorization query concerns a group resource
    When the broker lists the resource's supported permissions
    Then the supported permissions are exactly Read,Describe,Delete,DescribeConfigs,AlterConfigs

  Scenario: Clusters expose exactly their supported permissions
    Given an authorization query concerns a cluster resource
    When the broker lists the resource's supported permissions
    Then the supported permissions are exactly Create,Alter,Describe,ClusterAction,AlterConfigs,DescribeConfigs,IdempotentWrite

  Scenario Outline: Kafka operation codes determine the advertised permission bits
    Given the authorized operation is <operation>
    When the operation is encoded in the authorized-operations bitfield
    Then the operation contributes mask <mask>

    Examples:
      | case             | operation       | mask |
      | read             | Read            | 8    |
      | write            | Write           | 16   |
      | create           | Create          | 32   |
      | delete           | Delete          | 64   |
      | alter            | Alter           | 128  |
      | describe         | Describe        | 256  |
      | cluster action   | ClusterAction   | 512  |
      | describe configs | DescribeConfigs | 1024 |
      | alter configs    | AlterConfigs    | 2048 |
      | idempotent write | IdempotentWrite | 4096 |
