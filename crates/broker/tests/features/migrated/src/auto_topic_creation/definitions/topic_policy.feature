Feature: Auto-created topics inherit coordinator policy and explicitly supplied defaults

  Scenario: __consumer_offsets takes the offsets coordinator policy
    Given ordinary topic defaults are 6 partitions and replication 7
    And the offsets coordinator topic uses 11 partitions and replication 3
    And the requested automatic topic name is __consumer_offsets
    When the manager builds the automatic topic definition
    Then the complete automatic topic definition is:
      | field       | value                                                                                        |
      | name        | __consumer_offsets                                                                           |
      | partitions  | 11                                                                                           |
      | replication | 3                                                                                            |
      | configs     | [["cleanup.policy","compact"],["compression.type","producer"],["segment.bytes","104857600"]] |

  Scenario: __transaction_state takes the transaction coordinator policy
    Given ordinary topic defaults are 6 partitions and replication 7
    And the transaction coordinator topic uses 12 partitions, replication 2 and minimum ISR 2
    And the requested automatic topic name is __transaction_state
    When the manager builds the automatic topic definition
    Then the complete automatic topic definition is:
      | field       | value                                                                                                                                                                    |
      | name        | __transaction_state                                                                                                                                                      |
      | partitions  | 12                                                                                                                                                                       |
      | replication | 2                                                                                                                                                                        |
      | configs     | [["cleanup.policy","compact"],["compression.type","uncompressed"],["min.insync.replicas","2"],["segment.bytes","104857600"],["unclean.leader.election.enable","false"]] |

  Scenario: __share_group_state takes the share coordinator policy
    Given ordinary topic defaults are 6 partitions and replication 7
    And the share coordinator topic uses 13 partitions, replication 4 and minimum ISR 3
    And the requested automatic topic name is __share_group_state
    When the manager builds the automatic topic definition
    Then the complete automatic topic definition is:
      | field       | value                                                                                                                                         |
      | name        | __share_group_state                                                                                                                           |
      | partitions  | 13                                                                                                                                            |
      | replication | 4                                                                                                                                             |
      | configs     | [["cleanup.policy","delete"],["compression.type","producer"],["min.insync.replicas","3"],["retention.ms","-1"],["segment.bytes","104857600"]] |

  Scenario: __barrier_state takes the barrier coordinator policy
    Given ordinary topic defaults are 6 partitions and replication 7
    And the barrier coordinator topic uses 14 partitions and replication 5
    And the requested automatic topic name is __barrier_state
    When the manager builds the automatic topic definition
    Then the complete automatic topic definition is:
      | field       | value                          |
      | name        | __barrier_state                |
      | partitions  | 14                             |
      | replication | 5                              |
      | configs     | [["cleanup.policy","compact"]] |

  Scenario: An ordinary topic leaves unsupplied defaults to the controller
    Given ordinary topic defaults are 6 partitions and replication 7
    And the requested automatic topic name is orders
    When the manager builds the automatic topic definition
    Then the complete automatic topic definition is:
      | field       | value  |
      | name        | orders |
      | partitions  | -1     |
      | replication | -1     |
      | configs     | []     |

  Scenario: __remote_log_metadata is created as an ordinary topic
    Given ordinary topic defaults are 6 partitions and replication 7
    And the requested automatic topic name is __remote_log_metadata
    When the manager builds the automatic topic definition
    Then the complete automatic topic definition is:
      | field       | value                 |
      | name        | __remote_log_metadata |
      | partitions  | -1                    |
      | replication | -1                    |
      | configs     | []                    |

  Scenario: An ordinary topic takes an explicitly supplied partition count
    Given ordinary topic defaults are 6 partitions and replication 7
    And the operator explicitly supplied topic partitions true and replication false
    And the requested automatic topic name is orders
    When the manager builds the automatic topic definition
    Then the complete automatic topic definition is:
      | field       | value  |
      | name        | orders |
      | partitions  | 6      |
      | replication | -1     |
      | configs     | []     |

  Scenario: An ordinary topic takes explicitly supplied partitions and replication
    Given ordinary topic defaults are 6 partitions and replication 7
    And the operator explicitly supplied topic partitions true and replication true
    And the requested automatic topic name is orders
    When the manager builds the automatic topic definition
    Then the complete automatic topic definition is:
      | field       | value  |
      | name        | orders |
      | partitions  | 6      |
      | replication | 7      |
      | configs     | []     |
