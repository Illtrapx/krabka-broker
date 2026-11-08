Feature: Kafka listener-prefixed broker key resolution
  A listener or mechanism prefix resolves to the same base key and ConfigDef
  type. Unknown base keys remain unknown rather than acquiring a guessed type.

  Scenario Outline: Configured names retain their base key and Kafka type
    Given the broker configuration key is <configured>
    When the broker catalog resolves that configured key
    Then the configured name resolves to base key <base> with Kafka type <kind>

    Examples:
      | case                                       | configured | base | kind |
      | a base key                                 | num.io.threads | num.io.threads | INT |
      | a listener-prefixed string                 | listener.name.external.ssl.keystore.location | ssl.keystore.location | STRING |
      | a listener-prefixed password               | listener.name.external.ssl.keystore.password | ssl.keystore.password | PASSWORD |
      | a listener and mechanism prefixed password | listener.name.external.plain.sasl.jaas.config | sasl.jaas.config | PASSWORD |

  Scenario Outline: Unknown configured names remain unresolved
    Given the broker configuration key is <configured>
    When the broker catalog resolves that configured key
    Then the configured name does not resolve to a broker key

    Examples:
      | case                             | configured |
      | an unknown listener-prefixed key | listener.name.external.no.such.key |
      | an unknown key                   | no.such.key |
