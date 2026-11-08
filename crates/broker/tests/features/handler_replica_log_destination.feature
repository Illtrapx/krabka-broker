Feature: Replica destination identity and future directory length

  Scenario Outline: Exact path spelling and future directory length determine refusal
    Given an online configured log directory with a symbolic link and no hosted orders partition
    And the replica move names destination <destination> and topic <topic>
    When AlterReplicaLogDirs version 2 processes the destination
    Then the complete replica move response has partition error <error>

    Examples:
      | case                                     | destination            | topic       | error |
      | the configured directory spelled exactly | configured             | orders      | 9     |
      | a trailing slash                         | configured/            | orders      | 57    |
      | a trailing dot segment                   | configured/.           | orders      | 57    |
      | a parent segment                         | configured/../basename | orders      | 57    |
      | a relative path                          | relative-configured    | orders      | 57    |
      | a symlink to the directory               | symlink                | orders      | 57    |
      | the longest future directory name        | configured             | 213-times-t | 9     |
      | a future directory name one too long     | configured             | 214-times-t | 17    |
      | a too-long name outranks the path check  | configured/            | 214-times-t | 17    |
