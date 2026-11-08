Feature: DescribeAcls follows Kafka resource pattern matching
  Scenario Outline: Pattern filters distinguish null names exact names and matching prefixes
    Given topic read ACLs for User:alice contain these resource patterns
      | pattern  | name |
      | literal  | foo  |
      | literal  | *    |
      | prefixed | f    |
      | prefixed | fo   |
      | literal  | food |
      | prefixed | bar  |
    And DescribeAcls filters pattern type <pattern> and resource name <name>
    When an admin describes matching ACLs and the result is sorted by resource name
    Then the complete ACL description contains patterns <listed>
    Examples:
      | case                         | pattern  | name  | listed                                                                 |
      | any with a null name         | any      | null  | literal:*;prefixed:bar;prefixed:f;prefixed:fo;literal:foo;literal:food |
      | any with an empty name       | any      | empty | none                                                                   |
      | any with a name              | any      | foo   | literal:foo                                                            |
      | match with a null name       | match    | null  | literal:*;prefixed:bar;prefixed:f;prefixed:fo;literal:foo;literal:food |
      | match with an empty name     | match    | empty | literal:*                                                              |
      | match with a name            | match    | foo   | literal:*;prefixed:f;prefixed:fo;literal:foo                           |
      | literal with a null name     | literal  | null  | literal:*;literal:foo;literal:food                                     |
      | literal with an empty name   | literal  | empty | none                                                                   |
      | literal with a name          | literal  | foo   | literal:foo                                                            |
      | prefixed with a null name    | prefixed | null  | prefixed:bar;prefixed:f;prefixed:fo                                    |
      | prefixed with an empty name  | prefixed | empty | none                                                                   |
      | prefixed with a literal name | prefixed | foo   | none                                                                   |
