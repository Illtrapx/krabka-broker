Feature: Native Streams task assignor selection
  Scenario Outline: Selecting a registered implementation executes its own assignment logic
    Given native Streams assignors first and second pin tasks to different members
    When the Streams group selects <selection> and computes its target
    Then the selected assignor is <reported> and all active tasks belong to <owner>

    Examples:
      | case                                         | selection | reported | owner |
      | the default is the first registered assignor | default   | first    | a     |
      | the first assignor by name                   | first     | first    | a     |
      | the second assignor by name                  | second    | second   | b     |
