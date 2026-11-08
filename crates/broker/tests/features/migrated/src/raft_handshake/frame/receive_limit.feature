Feature: Controller SASL receive size is checked before payload allocation

  Scenario Outline: Check the inclusive SASL receive-size limit before payload reads
    Given the controller peer sent size prefix <size> and closed without a payload
    When the controller handshake admits a frame with SASL receive limit 4096
    Then frame admission reaches <outcome>

    Examples:
      | case                         | size       | outcome                                  |
      | exactly at the limit         | 4096       | payload reading after an admitted prefix |
      | one byte over the limit      | 4097       | SASL receive-size failure                |
      | the largest unsigned size    | 4294967295 | SASL receive-size failure                |
      | a size with the sign bit set | 2147483648 | SASL receive-size failure                |
