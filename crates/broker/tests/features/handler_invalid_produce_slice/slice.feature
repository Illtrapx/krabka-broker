Feature: Produce framing rejects ambiguous fields before checking record CRC
  Scenario Outline: Invalid verbatim records retain Kafka corruption and invalid-record distinctions
    Given a Produce records slice contains <shape>
    When Produce version 13 prepares that records slice without recompression
    Then the records slice is rejected with Kafka error <code>
    Examples:
      | case                             | shape                                     | code |
      | crc mismatch alone               | a CRC mismatch                            | 2    |
      | crc mismatch then a second batch | a CRC mismatch followed by a second batch | 87   |
      | two valid batches                | two valid batches                         | 87   |
      | batch size below header          | batch size 13                             | 2    |
      | negative batch size              | batch size -1                             | 2    |
      | batch size beyond slice          | batch size 20 truncated to 32 bytes       | 2    |
      | magic three                      | magic 3                                   | 2    |
      | magic 255                        | magic 255                                 | 2    |
      | record body short by one byte    | one byte missing from the record body     | 87   |
      | slice shorter than batch header  | only the first 11 bytes                   | 87   |
