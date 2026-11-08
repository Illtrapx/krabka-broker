Feature: Client telemetry validation and time windows
  # id xor changes the assigned subscription id a push sends; zero sends it unchanged.
  # Each scenario replays the client's earlier requests, then checks one more.

  Rule: Push validation order and timestamps across one client session

    Scenario: The first push after the subscription is accepted
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      When the client pushes at 1000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | true                  | 10            | false       |
      Then the telemetry push returns Kafka code 0

    Scenario: A push inside the push interval is throttled
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
      When the client pushes at 2000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | true                  | 10            | false       |
      Then the telemetry push returns Kafka code 89

    Scenario: Throttling is checked before the subscription id
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
        | 2000   | push    | 0      | true                  | 10            | false       |
      When the client pushes at 3000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 21845  | true                  | 10            | false       |
      Then the telemetry push returns Kafka code 89

    Scenario: A push with an unknown subscription id is refused after the interval
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
        | 2000   | push    | 0      | true                  | 10            | false       |
        | 3000   | push    | 21845  | true                  | 10            | false       |
      When the client pushes at 61000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 21845  | true                  | 10            | false       |
      Then the telemetry push returns Kafka code 117

    Scenario: A refused push still starts a new push interval
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
        | 2000   | push    | 0      | true                  | 10            | false       |
        | 3000   | push    | 21845  | true                  | 10            | false       |
        | 61000  | push    | 21845  | true                  | 10            | false       |
      When the client pushes at 62000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | true                  | 10            | false       |
      Then the telemetry push returns Kafka code 89

    Scenario: A push in an unsupported compression type is refused
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
        | 2000   | push    | 0      | true                  | 10            | false       |
        | 3000   | push    | 21845  | true                  | 10            | false       |
        | 61000  | push    | 21845  | true                  | 10            | false       |
        | 62000  | push    | 0      | true                  | 10            | false       |
      When the client pushes at 122000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | false                 | 4096          | false       |
      Then the telemetry push returns Kafka code 76

    Scenario: A payload above the size limit is too large
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
        | 2000   | push    | 0      | true                  | 10            | false       |
        | 3000   | push    | 21845  | true                  | 10            | false       |
        | 61000  | push    | 21845  | true                  | 10            | false       |
        | 62000  | push    | 0      | true                  | 10            | false       |
        | 122000 | push    | 0      | false                 | 4096          | false       |
      When the client pushes at 183000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | true                  | 1025          | false       |
      Then the telemetry push returns Kafka code 118

    Scenario: A payload at the size limit is accepted
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
        | 2000   | push    | 0      | true                  | 10            | false       |
        | 3000   | push    | 21845  | true                  | 10            | false       |
        | 61000  | push    | 21845  | true                  | 10            | false       |
        | 62000  | push    | 0      | true                  | 10            | false       |
        | 122000 | push    | 0      | false                 | 4096          | false       |
        | 183000 | push    | 0      | true                  | 1025          | false       |
      When the client pushes at 244000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | true                  | 1024          | false       |
      Then the telemetry push returns Kafka code 0

    Scenario: A terminating push is accepted inside the push interval
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
        | 2000   | push    | 0      | true                  | 10            | false       |
        | 3000   | push    | 21845  | true                  | 10            | false       |
        | 61000  | push    | 21845  | true                  | 10            | false       |
        | 62000  | push    | 0      | true                  | 10            | false       |
        | 122000 | push    | 0      | false                 | 4096          | false       |
        | 183000 | push    | 0      | true                  | 1025          | false       |
        | 244000 | push    | 0      | true                  | 1024          | false       |
      When the client pushes at 245000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | true                  | 10            | true        |
      Then the telemetry push returns Kafka code 0

    Scenario: A push after the terminating push is invalid
      Given a client gets all metrics at time zero with interval 60000 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 1000   | push    | 0      | true                  | 10            | false       |
        | 2000   | push    | 0      | true                  | 10            | false       |
        | 3000   | push    | 21845  | true                  | 10            | false       |
        | 61000  | push    | 21845  | true                  | 10            | false       |
        | 62000  | push    | 0      | true                  | 10            | false       |
        | 122000 | push    | 0      | false                 | 4096          | false       |
        | 183000 | push    | 0      | true                  | 1025          | false       |
        | 244000 | push    | 0      | true                  | 1024          | false       |
        | 245000 | push    | 0      | true                  | 10            | true        |
      When the client pushes at 400000 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | true                  | 10            | false       |
      Then the telemetry push returns Kafka code 42

  Rule: Get throttling recovers after errors that request a new subscription

    Scenario: A subscription request inside the interval is throttled
      Given a client gets all metrics at time zero with interval 100 milliseconds
      When the client requests its subscription at 99 milliseconds
      Then the subscription request returns Kafka code 89

    Scenario: A subscription request at the interval is assigned
      Given a client gets all metrics at time zero with interval 100 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 99     | get     | -      | -                     | -             | -           |
      When the client requests its subscription at 100 milliseconds
      Then the subscription request returns Kafka code 0

    Scenario: A push after the second subscription request is accepted
      Given a client gets all metrics at time zero with interval 100 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 99     | get     | -      | -                     | -             | -           |
        | 100    | get     | -      | -                     | -             | -           |
      When the client pushes at 150 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | true                  | 10            | false       |
      Then the telemetry push returns Kafka code 0

    Scenario: A subscription request after an accepted push is throttled
      Given a client gets all metrics at time zero with interval 100 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 99     | get     | -      | -                     | -             | -           |
        | 100    | get     | -      | -                     | -             | -           |
        | 150    | push    | 0      | true                  | 10            | false       |
      When the client requests its subscription at 200 milliseconds
      Then the subscription request returns Kafka code 89

    Scenario: A push with a stale subscription id is refused
      Given a client gets all metrics at time zero with interval 100 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 99     | get     | -      | -                     | -             | -           |
        | 100    | get     | -      | -                     | -             | -           |
        | 150    | push    | 0      | true                  | 10            | false       |
        | 200    | get     | -      | -                     | -             | -           |
      When the client pushes at 260 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 1      | true                  | 10            | false       |
      Then the telemetry push returns Kafka code 117

    Scenario: An unknown subscription id lets the client request a subscription at once
      Given a client gets all metrics at time zero with interval 100 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 99     | get     | -      | -                     | -             | -           |
        | 100    | get     | -      | -                     | -             | -           |
        | 150    | push    | 0      | true                  | 10            | false       |
        | 200    | get     | -      | -                     | -             | -           |
        | 260    | push    | 1      | true                  | 10            | false       |
      When the client requests its subscription at 261 milliseconds
      Then the subscription request returns Kafka code 0

    Scenario: Only the first subscription request after the error skips throttling
      Given a client gets all metrics at time zero with interval 100 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 99     | get     | -      | -                     | -             | -           |
        | 100    | get     | -      | -                     | -             | -           |
        | 150    | push    | 0      | true                  | 10            | false       |
        | 200    | get     | -      | -                     | -             | -           |
        | 260    | push    | 1      | true                  | 10            | false       |
        | 261    | get     | -      | -                     | -             | -           |
      When the client requests its subscription at 262 milliseconds
      Then the subscription request returns Kafka code 89

    Scenario: A push in an unsupported compression type asks for a new subscription
      Given a client gets all metrics at time zero with interval 100 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 99     | get     | -      | -                     | -             | -           |
        | 100    | get     | -      | -                     | -             | -           |
        | 150    | push    | 0      | true                  | 10            | false       |
        | 200    | get     | -      | -                     | -             | -           |
        | 260    | push    | 1      | true                  | 10            | false       |
        | 261    | get     | -      | -                     | -             | -           |
        | 262    | get     | -      | -                     | -             | -           |
      When the client pushes at 400 milliseconds with:
        | id xor | compression supported | payload bytes | terminating |
        | 0      | false                 | 10            | false       |
      Then the telemetry push returns Kafka code 76

    Scenario: An unsupported compression type lets the client request a subscription at once
      Given a client gets all metrics at time zero with interval 100 milliseconds
      And the client has already sent these telemetry requests:
        | at     | request | id xor | compression supported | payload bytes | terminating |
        | 99     | get     | -      | -                     | -             | -           |
        | 100    | get     | -      | -                     | -             | -           |
        | 150    | push    | 0      | true                  | 10            | false       |
        | 200    | get     | -      | -                     | -             | -           |
        | 260    | push    | 1      | true                  | 10            | false       |
        | 261    | get     | -      | -                     | -             | -           |
        | 262    | get     | -      | -                     | -             | -           |
        | 400    | push    | 0      | false                 | 10            | false       |
      When the client requests its subscription at 401 milliseconds
      Then the subscription request returns Kafka code 0
