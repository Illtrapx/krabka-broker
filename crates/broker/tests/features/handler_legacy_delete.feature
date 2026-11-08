Feature: DeleteGroups errors respect the request version
  Scenario Outline: legacy_delete_error_mapping
    Given DeleteGroups version <version> with coordinator error <input>
    When the handler renders the group deletion result
    Then the result has error <output> and message <message>

    Examples:
      | case                     | version | input | output | message |
      | v0 hides a newer error   | 0       | 134   | -1     | null    |
      | v1 hides a newer error   | 1       | 134   | -1     | null    |
      | v2 hides a newer error   | 2       | 134   | -1     | null    |
      | v3 keeps a newer error   | 3       | 134   | 134    | generic |
      | v2 success               | 2       | 0     | 0      | null    |
      | v3 success               | 3       | 0     | 0      | null    |
      | v2 authorization failure | 2       | 30    | 30     | null    |
      | v3 authorization failure | 3       | 30    | 30     | null    |
      | v2 group not found       | 2       | 69    | 69     | null    |
      | v3 group not found       | 3       | 69    | 69     | null    |
      | v2 non-empty group       | 2       | 68    | 68     | null    |
      | v3 non-empty group       | 3       | 68    | 68     | null    |
