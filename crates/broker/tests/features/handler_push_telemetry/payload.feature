Feature: PushTelemetry validates payloads after subscription assignment
  Scenario Outline: Telemetry payload framing compression decoding and size limits follow the selected Kafka version
    Given a telemetry client has obtained a subscription with a 1024-byte limit and unstable API versions <unstable>
    And the telemetry push carries <payload> using compression ID <compression>
    When the client pushes telemetry using its assigned subscription
    Then the complete telemetry response has error <code>
    Examples:
      | case                                | unstable | payload                               | compression | code |
      | stable gzip otlp                    | false    | gzip OTLP                             | 1           | 87   |
      | stable uncompressed otlp            | false    | uncompressed OTLP                     | 0           | 87   |
      | stable empty payload                | false    | empty bytes                           | 1           | 0    |
      | stable unknown compression nine     | false    | gzip OTLP                             | 9           | 76   |
      | stable unknown compression twelve   | false    | gzip OTLP                             | 12          | 76   |
      | stable negative compression         | false    | gzip OTLP                             | -1          | 76   |
      | stable payload over limit           | false    | 1025 uncompressed bytes               | 0           | 118  |
      | stable gzip bomb                    | false    | 65536 zero bytes compressed with gzip | 1           | 87   |
      | stable gzip non otlp                | false    | gzip bytes that are not OTLP          | 1           | 87   |
      | stable non gzip bytes               | false    | bytes that are not gzip               | 1           | 87   |
      | unstable gzip otlp                  | true     | gzip OTLP                             | 1           | 87   |
      | unstable uncompressed otlp          | true     | uncompressed OTLP                     | 0           | 87   |
      | unstable empty payload              | true     | empty bytes                           | 1           | 0    |
      | unstable unknown compression nine   | true     | gzip OTLP                             | 9           | 76   |
      | unstable unknown compression twelve | true     | gzip OTLP                             | 12          | 76   |
      | unstable negative compression       | true     | gzip OTLP                             | -1          | 76   |
      | unstable payload over limit         | true     | 1025 uncompressed bytes               | 0           | 118  |
      | unstable gzip bomb                  | true     | 65536 zero bytes compressed with gzip | 1           | 118  |
      | unstable gzip non otlp              | true     | gzip bytes that are not OTLP          | 1           | 87   |
      | unstable non gzip bytes             | true     | bytes that are not gzip               | 1           | 87   |
