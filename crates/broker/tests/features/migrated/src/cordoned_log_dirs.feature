Feature: Cordoned directories resolve to configured broker log paths
  An administrator can select existing directories or all directories using a wildcard.

  Scenario Outline: Resolve a legal cordoning selection
    Given the broker log directories are /d1 and /d2
    And cordoned.log.dirs is JSON <value>
    When the cordoned log directories are resolved
    Then the ordered cordoned directories are JSON <paths>

    Examples:
      | case                          | value       | paths         |
      | an empty selection            | ""          | []            |
      | a blank selection             | "  "        | []            |
      | one directory                 | "/d1"       | ["/d1"]       |
      | directories in log.dirs order | "/d2 , /d1" | ["/d1","/d2"] |
      | a repeated directory          | "/d1,/d1"   | ["/d1"]       |
      | the wildcard                  | "*"         | ["/d1","/d2"] |

  Scenario Outline: Refuse an invalid cordoning selection
    Given the broker log directories are /d1 and /d2
    And cordoned.log.dirs is JSON <value>
    When the cordoned log directories are resolved
    Then the cordoning request fails with <message>

    Examples:
      | case                            | value       | message                                                                                                               |
      | a trailing empty entry          | "/d1,"      | Configuration 'cordoned.log.dirs' values must not be empty.                                                           |
      | the wildcard with another value | "*,/d1"     | requirement failed: When cordoned.log.dirs is set to *, it must not contain other values                              |
      | an unknown directory            | "/nope"     | requirement failed: All entries in cordoned.log.dirs must be present in log.dirs or log.dir. Missing entries : /nope  |
      | several unknown directories     | "/x,/d1,/y" | requirement failed: All entries in cordoned.log.dirs must be present in log.dirs or log.dir. Missing entries : /x, /y |
