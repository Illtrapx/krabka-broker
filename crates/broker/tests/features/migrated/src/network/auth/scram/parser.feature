Feature: SCRAM client-first grammar exposes only valid Kafka identities and extensions

  Scenario Outline: Parse a valid SCRAM first message
    Given a SCRAM client sends first message <message>
    When the broker parses the SCRAM client-first identity and extensions
    Then the SCRAM identity has authorization id <authorization_id>, SASL name <name>, and JSON extensions <extensions>

    Examples:
      | case                                 | message                               | authorization_id | name      | extensions                          |
      | a plain username                     | n,,n=alice,r=abc                      | unset            | alice     | []                                  |
      | an authorization id                  | n,a=alice,n=alice,r=abc               | alice            | alice     | []                                  |
      | a reserved mandatory extension       | n,,m=ext,n=alice,r=abc                | unset            | alice     | []                                  |
      | token extensions in order            | n,,n=tok,r=abc,tokenauth=true,other=x | unset            | tok       | [["tokenauth","true"],["other","x"]] |
      | an escaped comma and equals sign     | n,,n=a=2Cb=3Dc,r=abc                  | unset            | a=2Cb=3Dc | []                                  |

  Scenario Outline: Refuse a malformed SCRAM first message
    Given a SCRAM client sends first message <message>
    When the broker parses the SCRAM client-first identity and extensions
    Then the SCRAM client-first message is refused

    Examples:
      | case                              | message                          |
      | an unknown channel binding flag   | y,,n=alice,r=abc                 |
      | an empty username                 | n,,n=,r=abc                      |
      | an empty nonce                    | n,,n=alice,r=                    |
      | an invalid escape in the username | n,,n=a=41,r=abc                  |
      | an extension key with underscore  | n,,n=alice,r=abc,token_auth=true |
      | the nonce before the username     | n,,r=abc,n=alice                 |
