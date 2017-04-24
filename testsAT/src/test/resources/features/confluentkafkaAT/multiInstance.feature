@rest
Feature: Multi-instance testing

  Scenario: MultiInstance-Spec-01 - Scheduler MUST support a custom FrameworkInfo.name.
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/confluent-kafka-sec.json' as 'json' with:
      | $.id | UPDATE | confluent-kafka-sec2 |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | ${VAULT_TOKEN} |
      | $.env.FRAMEWORK_NAME| UPDATE | confluent-kafka-sec2 |
      | $.labels.DCOS_SERVICE_NAME | UPDATE | confluent-kafka-sec2 |
      | $.labels.DCOS_PACKAGE_FRAMEWORK_NAME | UPDATE | confluent-kafka-sec2 |
    Then the service response status must be '201'.
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w confluent-kafka-sec2 | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep broker | wc -l' contains '6'
    And I run 'dcos marathon task list confluent-kafka-sec2 | awk '{print $5}' | grep confluent-kafka-sec2' in the ssh connection and save the value in environment variable 'marathonTaskId'
    #DCOS dcos marathon task show check healtcheck status
    And in less than '600' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep healthCheckResults | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep '"alive": true' | wc -l' contains '1'

    #Checking Mesos framework info
    Given I obtain mesos master in cluster '${DCOS_IP}' and store it in environment variable 'mesosMaster'
    And I send requests to '!{mesosMaster}:${MESOS_API_PORT}'
    And I send a 'GET' request to '/frameworks'
    Then the service response status must be '200'.
    And I save element in position '0' in '$.frameworks[?(@.name == "marathon")].tasks[?(@.name == "confluent-kafka-sec")].name' in environment variable 'name1'
    And I save element in position '0' in '$.frameworks[?(@.name == "marathon")].tasks[?(@.name == "confluent-kafka-sec2")].name' in environment variable 'name2'
    And value stored in '!{name1}' is 'confluent-kafka-sec'
    And value stored in '!{name2}' is 'confluent-kafka-sec2'


  Scenario: MultiInstance-Spec-01.1 - Having two instances of the same service, each one MUST have its own resources.
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I run 'dcos package install --cli confluent-kafka-sec' in the ssh connection
    When I run 'dcos confluent-kafka-sec --name confluent-kafka-sec topic create multiinstancetest' in the ssh connection
    Then the command output contains 'Created topic'
    And I wait '1' seconds
    When I run 'dcos confluent-kafka-sec --name confluent-kafka-sec topic list' in the ssh connection
    Then the command output contains 'multiinstancetest'
    When I run 'dcos confluent-kafka-sec --name confluent-kafka-sec2 topic list' in the ssh connection
    Then the command output does not contain 'multiinstancetest'
    When I run 'dcos confluent-kafka-sec --name confluent-kafka-sec2 topic create multiinstancecheck' in the ssh connection
    Then the command output contains 'Created topic'
    And I wait '1' seconds
    When I run 'dcos confluent-kafka-sec --name confluent-kafka-sec topic list' in the ssh connection
    Then the command output does not contain 'multiinstancecheck'
    When I run 'dcos confluent-kafka-sec --name confluent-kafka-sec2 topic list' in the ssh connection
    Then the command output contains 'multiinstancecheck'


  Scenario: Uninstall service second instance
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    When I run 'dcos package uninstall confluent-kafka-sec --app-id=confluent-kafka-sec2' in the ssh connection
    And I run 'dcos marathon task list' in the ssh connection
    Then the command output does not contain 'confluent-kafka-sec2'

    #Checking service first instance is fully up & running
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I send requests to '${MASTER_HOSTNAME}' without port
    Then in less than '120' seconds, checking each '20' seconds, I send a 'GET' request to '/mesos_dns/v1/services/_confluent-kafka-sec._tcp.marathon.mesos' so that the response contains '"service": "_confluent-kafka-sec._tcp.marathon.mesos"'
