Feature: Kafka offset lookup timestamps and protocol compatibility
  Special log positions have fixed wire timestamps. Newer lookup modes must
  be refused by request versions that cannot express them.

  Scenario Outline: Named positions retain their Kafka wire timestamps
    Given the client requests the <position> log position
    When the position is encoded as a Kafka request timestamp
    Then the wire timestamp is <timestamp>

    Examples:
      | case                    | position                | timestamp |
      | earliest                | earliest                | -2        |
      | latest                  | latest                  | -1        |
      | maximum timestamp       | maximum-timestamp       | -3        |
      | earliest local          | earliest-local          | -4        |
      | latest tiered           | latest-tiered           | -5        |
      | earliest pending upload | earliest-pending-upload | -6        |

  Scenario Outline: Offset lookup modes require their introducing protocol version
    Given a ListOffsets version <version> request carries timestamp <timestamp>
    When the broker classifies the ListOffsets timestamp
    Then the timestamp is <support> by that protocol version

    Examples:
      | case                         | timestamp | version | support     |
      | earliest                     | -2        | 0       | supported   |
      | latest                       | -1        | 0       | supported   |
      | before maximum timestamp     | -3        | 6       | unsupported |
      | maximum timestamp introduced | -3        | 7       | supported   |
      | before local lookup          | -4        | 7       | unsupported |
      | local lookup introduced      | -4        | 8       | supported   |
      | before tiered lookup         | -5        | 8       | unsupported |
      | tiered lookup introduced     | -5        | 9       | supported   |
      | before pending upload lookup | -6        | 10      | unsupported |
      | pending upload introduced    | -6        | 11      | supported   |
      | unknown negative sentinel    | -7        | 11      | unsupported |
      | ordinary timestamp lookup    | 0         | 1       | supported   |
