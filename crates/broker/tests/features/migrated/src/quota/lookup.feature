Feature: Producer quota resolution follows Kafka user and client precedence
  A configured default entity can supply the rate while metric tags still bind
  the charged bucket to the actual user and client.

  Scenario: Named user-client pair overrides a named user with default client
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | alice   | app       | 1000             |
      | alice   | default   | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice and client app at 1000 bytes per second

  Scenario: Named user with default client overrides user-only quota
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | alice   | default   | 1000             |
      | alice   | -         | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice and client app at 1000 bytes per second

  Scenario: Named user overrides a default user with named client
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | alice   | -         | 1000             |
      | default | app       | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice alone at 1000 bytes per second

  Scenario: Default user with named client overrides the default pair
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | default | app       | 1000             |
      | default | default   | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice and client app at 1000 bytes per second

  Scenario: Default pair overrides default user-only quota
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | default | default   | 1000             |
      | default | -         | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice and client app at 1000 bytes per second

  Scenario: Default user overrides a named client-only quota
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | default | -         | 1000             |
      | -       | app       | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice alone at 1000 bytes per second

  Scenario: Named client overrides default client quota
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | -       | app       | 1000             |
      | -       | default   | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of client app alone at 1000 bytes per second

  Scenario: Named user overrides the default user-client pair
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | alice   | -         | 1000             |
      | default | default   | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice alone at 1000 bytes per second

  Scenario: Named user with default client overrides default user with named client
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | alice   | default   | 1000             |
      | default | app       | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice and client app at 1000 bytes per second

  Scenario: Named user quota overrides default user with a matching client
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | alice   | -         | 1000             |
      | default | app       | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice alone at 1000 bytes per second

  Scenario: Default user overrides matching client-only quota
    Given the cluster has these producer quotas:
      | user    | client id | bytes per second |
      | default | -         | 1000             |
      | -       | app       | 5000             |
    When the producer quota for user alice and client app is resolved
    Then the quota charges the bucket of user alice alone at 1000 bytes per second
