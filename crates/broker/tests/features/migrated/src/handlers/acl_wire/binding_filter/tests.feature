Feature: Kafka ACL resource pattern queries
  Null and empty resource names differ. MATCH queries include covering prefixes
  and the literal wildcard, while exact pattern queries retain their own scope.

  Scenario Outline: Resource filters select exactly Kafka's matching ACL entries
    Given these topic ACL resource patterns are stored in order:
      | name | pattern  |
      | foo  | Literal  |
      | *    | Literal  |
      | f    | Prefixed |
      | fo   | Prefixed |
      | bar  | Prefixed |
      | food | Literal  |
    And the ACL query uses pattern <pattern> and resource name <name>
    When the broker matches the query against stored ACL resources
    Then the matching resource names are exactly <expected>

    Examples:
      | case                                    | pattern  | name   | expected                          |
      | any with a null name matches all        | Any      | null   | ["foo","*","f","fo","bar","food"] |
      | any with an empty name matches none     | Any      | ""     | []                                |
      | any with a name matches it exactly      | Any      | "foo"  | ["foo"]                           |
      | any with the wildcard name is literal   | Any      | "*"    | ["*"]                             |
      | match with a null name matches all      | Match    | null   | ["foo","*","f","fo","bar","food"] |
      | match with an empty name hits wildcard  | Match    | ""     | ["*"]                             |
      | match adds covering prefixes            | Match    | "foo"  | ["foo","*","f","fo"]              |
      | match on a longer name takes all covers | Match    | "food" | ["*","f","fo","food"]             |
      | literal with a null name takes literals | Literal  | null   | ["foo","*","food"]                |
      | literal with an empty name matches none | Literal  | ""     | []                                |
      | literal with a name matches it exactly  | Literal  | "foo"  | ["foo"]                           |
      | prefixed with a null name takes prefix  | Prefixed | null   | ["f","fo","bar"]                  |
      | prefixed with a literal name finds none | Prefixed | "foo"  | []                                |
