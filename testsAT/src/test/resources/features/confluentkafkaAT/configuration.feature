  @rest
  Feature: Configuration testing

  Scenario: Config-Spec-01 - Deploy a service with custom label
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I obtain mesos master in cluster '${DCOS_IP}' and store it in environment variable 'mesosMaster'
    When I add a new DCOS label with key 'TEST' and value 'TEST' to the service 'confluent-kafka-sec'
    Then in less than '60' seconds, checking each '10' seconds, the command output 'dcos task | grep confluent-kafka-sec | grep R | wc -l' contains '1'
    Given I send requests to '!{mesosMaster}:${MESOS_API_PORT}'
    When I send a 'GET' request to '/frameworks'
    Then the service response status must be '200'.
    And I save element in position '0' in '$.frameworks[?(@.name == "marathon")].tasks[?(@.name == "confluent-kafka-sec")].labels' in environment variable 'labels'
    And value stored in 'labels' contains '"value":"TEST","key":"TEST"'