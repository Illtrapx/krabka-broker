Feature: Metadata topic identity resolution changes at Kafka API version 12
  Scenario Outline: Names and UUIDs resolve according to the requested Kafka version
    Given topics resolution-a and resolution-b exist with their own UUIDs and a complete metadata baseline
    And Metadata API version <version> carries topic references <rows>
    When the broker answers the versioned topic metadata request
    Then the complete Metadata response contains ordered topic rows <expected>
    Examples:
      | case                         | version | rows                                     | expected                            |
      | names before version twelve  | 11      | resolution-a/zero                        | described resolution-a              |
      | uuid wins over name          | 12      | resolution-a/resolution-b                | described resolution-b              |
      | zero uuid falls back to name | 12      | resolution-a/zero;null/resolution-b      | described resolution-b              |
      | unknown uuid                 | 12      | resolution-a/unknown                     | unknown UUID                        |
      | null names resolve by uuid   | 13      | null/unknown;null/resolution-a;null/zero | unknown UUID;described resolution-a |
      | repeated uuid described once | 13      | null/resolution-a;null/resolution-a      | described resolution-a              |
      | repeated name described once | 12      | resolution-a/zero;resolution-a/zero      | described resolution-a              |
      | unknown name                 | 12      | no-such-topic/zero                       | unknown name                        |

  Scenario Outline: Invalid UUID or null-name combinations fail the complete versioned request
    Given topics resolution-a and resolution-b exist with their own UUIDs and a complete metadata baseline
    And Metadata API version <version> carries topic references <rows>
    When the broker answers the versioned topic metadata request
    Then the complete Metadata request error response has code <code>
    Examples:
      | case                                          | version | rows                           | code |
      | uuid before version twelve                    | 11      | resolution-a/resolution-a      | 42   |
      | null name before version eleven               | 10      | null/zero                      | 42   |
      | null name with unknown uuid at version eleven | 11      | null/unknown;resolution-a/zero | 42   |
      | null name with zero uuid at version twelve    | 12      | null/zero;resolution-a/zero    | -1   |
      | null name with zero uuid at version thirteen  | 13      | null/zero                      | -1   |
