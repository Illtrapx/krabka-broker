Feature: ListOffsets applies Kafka lagging-high-watermark fencing to lookup results
  Scenario Outline: Lookup kind and candidate position determine whether an offset is available
    Given a lagging high watermark bounds <kind> offset candidate <candidate> before offset 3
    When ListOffsets decides whether the lagging high watermark fences the result
    Then the candidate is fenced <expected>
    Examples:
      | case                              | kind                    | candidate | expected |
      | latest above watermark            | latest                  | 7         | true     |
      | latest at zero                    | latest                  | 0         | true     |
      | earliest                          | earliest                | 0         | false    |
      | earliest local                    | earliest-local          | 0         | false    |
      | timestamp below watermark         | timestamp               | 2         | false    |
      | timestamp at watermark            | timestamp               | 3         | true     |
      | timestamp above watermark         | timestamp               | 5         | true     |
      | timestamp not found               | timestamp               | -1        | true     |
      | maximum timestamp below watermark | maximum-timestamp       | 2         | false    |
      | maximum timestamp at watermark    | maximum-timestamp       | 3         | true     |
      | maximum timestamp not found       | maximum-timestamp       | -1        | true     |
      | latest tiered below watermark     | latest-tiered           | 2         | false    |
      | latest tiered at watermark        | latest-tiered           | 3         | true     |
      | latest tiered not found           | latest-tiered           | -1        | false    |
      | pending upload below watermark    | earliest-pending-upload | 2         | false    |
      | pending upload above watermark    | earliest-pending-upload | 4         | true     |
      | pending upload not found          | earliest-pending-upload | -1        | false    |
