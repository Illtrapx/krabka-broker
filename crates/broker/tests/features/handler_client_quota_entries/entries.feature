Feature: AlterClientQuotas validates values entity identity and duplicate entries like Kafka

  Scenario Outline: Quota keys enforce their numeric type and scope while removals skip value validation
    Given user carol currently has producer byte rate 1024
    And quota entries name entities <entities> with operations <operations>
    When the quota controller validates entries with IP literals and localhost resolvable
    Then the quota results name entities <entities> with outcome <outcome> and records <records>
    Examples:
      | case                         | entities    | operations                       | outcome                                                              | records                                 |
      | valid byte rate              | user=alice  | set:producer_byte_rate=1024      | accepted                                                             | user=alice/producer_byte_rate=1024      |
      | unknown key                  | user=alice  | set:foo=1                        | Invalid configuration key foo                                        | none                                    |
      | removal skips key validation | user=alice  | remove:foo=0                     | accepted                                                             | none                                    |
      | removal of a stored quota    | user=carol  | remove:producer_byte_rate=0      | accepted                                                             | user=carol/producer_byte_rate=null      |
      | set to the stored value      | user=carol  | set:producer_byte_rate=1024      | accepted                                                             | none                                    |
      | zero byte rate               | user=alice  | set:producer_byte_rate=0         | Quota producer_byte_rate must be greater than 0                      | none                                    |
      | negative percentage          | user=alice  | set:request_percentage=-1        | Quota request_percentage must be greater than 0                      | none                                    |
      | fractional byte rate         | user=alice  | set:producer_byte_rate=1024.5    | producer_byte_rate cannot be a fractional value.                     | none                                    |
      | infinite byte rate           | user=alice  | set:consumer_byte_rate=inf       | Proposed value for consumer_byte_rate is too large for a LONG.       | none                                    |
      | fractional connection rate   | ip=10.0.0.1 | set:connection_creation_rate=1.5 | connection_creation_rate cannot be a fractional value.               | none                                    |
      | connection rate beyond INT   | ip=10.0.0.1 | set:connection_creation_rate=3e9 | Proposed value for connection_creation_rate is too large for an INT. | none                                    |
      | percentage above one hundred | user=alice  | set:request_percentage=250       | accepted                                                             | user=alice/request_percentage=250       |
      | infinite mutation rate       | user=alice  | set:controller_mutation_rate=inf | accepted                                                             | user=alice/controller_mutation_rate=inf |
      | IP-only key for a user       | user=alice  | set:connection_creation_rate=1   | Invalid configuration key connection_creation_rate                   | none                                    |
      | user-only key for an IP      | ip=10.0.0.1 | set:producer_byte_rate=1         | Invalid configuration key producer_byte_rate                         | none                                    |

  Scenario Outline: Entity rules preserve Kafka duplicate semantics and the records staged before a repeated entity
    Given user carol currently has producer byte rate 1024
    And quota entries name entities <entities> with operations <operations>
    When the quota controller validates entries with IP literals and localhost resolvable
    Then the quota results name entities <result_entities> with outcome <outcome> and records <records>
    Examples:
      | case                                     | entities                  | operations                                                    | result_entities           | outcome                                                                                 | records                                                                   |
      | IP combined with user                    | ip=10.0.0.1+user=alice    | set:connection_creation_rate=1                                | ip=10.0.0.1+user=alice    | Invalid quota entity combination, IP entity shouldnot be combined with User or ClientId | none                                                                      |
      | IPv6 literal and localhost               | ip=::1;ip=localhost       | set:connection_creation_rate=5;set:connection_creation_rate=6 | ip=::1;ip=localhost       | accepted                                                                                | ip=::1/connection_creation_rate=5;ip=localhost/connection_creation_rate=6 |
      | unresolvable host                        | ip=not-an-ip              | set:connection_creation_rate=1                                | ip=not-an-ip              | not-an-ip is not a valid IP or resolvable host.                                         | none                                                                      |
      | empty user                               | user=empty                | set:producer_byte_rate=1                                      | user=empty                | Empty user not supported                                                                | none                                                                      |
      | unknown entity type                      | group=g1                  | set:producer_byte_rate=1                                      | group=g1                  | Unhandled client quota entity type: group                                               | none                                                                      |
      | no entity                                | none                      | set:producer_byte_rate=1                                      | none                      | Invalid empty client quota entity                                                       | none                                                                      |
      | repeated key within one entry           | client-id=null+user=alice | set:producer_byte_rate=1,set:producer_byte_rate=2             | client-id=null+user=alice | Ignoring duplicate entity ClientQuotaEntity(entries={client-id=null, user=alice})       | none                                                                      |
      | repeated entity keeps the first records  | user=alice;user=alice     | set:producer_byte_rate=1;set:consumer_byte_rate=2             | user=alice                | Ignoring duplicate entity ClientQuotaEntity(entries={user=alice})                       | user=alice/producer_byte_rate=1                                           |
      | repeated entity type keeps the last name | user=a+user=b             | set:producer_byte_rate=1                                      | user=b                    | accepted                                                                                | user=b/producer_byte_rate=1                                               |
