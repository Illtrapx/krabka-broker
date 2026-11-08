Feature: Metadata version transition compatibility
  A transition crosses a format change only when a changed version lies above
  the lower endpoint and at or below the higher endpoint, in either direction.

  Scenario Outline: Metadata transition boundaries match Kafka's exclusive lower endpoint
    Given metadata changes from version <source> to version <target>
    When Kafka's metadata-change boundaries are traversed
    Then a metadata format change is crossed <changed>

    Examples:
      | case                                   | source | target | changed |
      | the same version                       | 25     | 25     | false   |
      | a downgrade between unchanged versions | 25     | 24     | false   |
      | an upgrade between unchanged versions  | 24     | 25     | false   |
      | a wide downgrade without a change      | 29     | 24     | false   |
      | a downgrade across version 23          | 25     | 22     | true    |
      | a downgrade onto version 23            | 25     | 23     | false   |
      | a downgrade from version 23            | 23     | 22     | true    |
      | a downgrade from version 17            | 17     | 15     | true    |
      | a downgrade below version 17           | 16     | 15     | false   |
      | a downgrade from version 13            | 13     | 12     | true    |
      | a downgrade below version 13           | 12     | 11     | false   |
      | a downgrade from version 30            | 30     | 29     | true    |
      | a downgrade from version 32            | 32     | 31     | true    |
      | a downgrade onto version 30            | 31     | 30     | false   |
      | a downgrade from version 8             | 8      | 7      | true    |
      | a downgrade from version 7             | 7      | 6      | true    |
      | a downgrade from version 33            | 33     | 32     | true    |
