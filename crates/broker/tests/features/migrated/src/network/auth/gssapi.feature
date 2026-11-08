Feature: Authenticated GSSAPI principals follow Kafka short-name rules
  DEFAULT maps service principals only in the configured local realm and
  explicit rules may supply their own realm or case conversion.

  Scenario Outline: Map authenticated principal <principal> to <user>
    Given GSSAPI short-name rules are JSON <rules> with configured realm <realm>
    And SSPI authenticated principal <principal>
    When the authenticated GSSAPI principal is mapped to a local user
    Then the local GSSAPI user is <user>

    Examples:
      | case                                    | rules                                        | realm     | principal                        | user  |
      | a user in the local realm               | ["DEFAULT"]                                  | REALM.COM | alice@realm.com                  | alice |
      | a service in the local realm            | ["DEFAULT"]                                  | REALM.COM | kafka/host.example.com@realm.com | kafka |
      | an explicit rule for another realm      | ["RULE:[1:$1@$0](.*@OTHER.REALM)s/@.*//"]    | unset     | alice@other.realm                | alice |
      | the first matching rule converts case   | ["RULE:[1:$1](ali)s/^/x/","RULE:[1:$1]/U"]   | unset     | alice@realm.com                  | ALICE |

  Scenario Outline: Refuse authenticated principal <principal> without a matching local rule
    Given GSSAPI short-name rules are JSON <rules> with configured realm <realm>
    And SSPI authenticated principal <principal>
    When the authenticated GSSAPI principal is mapped to a local user
    Then the GSSAPI principal cannot be mapped to a local user

    Examples:
      | case                                  | rules       | realm     | principal         |
      | a principal from a foreign realm      | ["DEFAULT"] | REALM.COM | alice@other.realm |
      | no local realm is configured          | ["DEFAULT"] | unset     | alice@other.realm |
      | no local realm matches the principal  | ["DEFAULT"] | unset     | alice@realm.com   |
      | a principal with three components     | ["DEFAULT"] | REALM.COM | a/b/c@realm.com   |
