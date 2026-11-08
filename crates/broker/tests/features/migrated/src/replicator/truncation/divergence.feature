Feature: Intersect follower and leader epoch histories

  Scenario Outline: Preserve only the shared epoch prefix
    Given follower epoch/end, leader epoch/end and local end <input>
    When the follower calculates its divergence truncation target
    Then the divergence truncation offset is <offset>

    Examples:
      | case                                         | input           | offset |
      | leader cannot place the epoch                | [4,8,4,-1,9]    | 9      |
      | follower cannot place the epoch              | [-1,-1,6,12,15] | 12     |
      | follower without the epoch has a shorter log | [-1,-1,6,20,15] | 15     |
      | leader diverged at a later epoch             | [4,10,5,12,15]  | 10     |
      | leader diverged beyond the local log end     | [4,10,5,12,8]   | 8      |
      | same epoch ends earlier on the leader        | [5,12,5,10,15]  | 10     |
      | same epoch ends earlier on the follower      | [5,10,5,12,15]  | 10     |
      | same epoch ends past the local log end       | [5,12,5,14,11]  | 11     |
