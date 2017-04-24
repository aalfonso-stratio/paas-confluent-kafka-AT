@rest
Feature: Installing / uninstalling testing with confluent-kafka-sec

  # InstallUninstall-Spec-01. A service CAN be installed from the CLI
  Scenario: Install confluent-kafka-sec
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/confluent-kafka-sec.json' as 'json' with:
      | $.id | UPDATE | confluent-kafka-sec |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | ${VAULT_TOKEN} |
    Then the service response status must be '201'.
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w confluent-kafka-sec | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep broker | wc -l' contains '3'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I run 'dcos marathon task list confluent-kafka-sec | awk '{print $5}' | grep confluent-kafka-sec' in the ssh connection and save the value in environment variable 'marathonTaskId'
    #DCOS dcos marathon task show check healtcheck status
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep healthCheckResults | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep '"alive": true' | wc -l' contains '1'




