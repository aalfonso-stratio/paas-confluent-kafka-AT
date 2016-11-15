@rest
Feature: Multi-instance testing

  Background: Setup PaaS REST client
    Given I obtain mesos master in cluster '${DCOS_CLUSTER}' and store it in environment variable 'mesosMaster'

  Scenario: MultiInstance-Spec-01 - Scheduler MUST support a custom FrameworkInfo.name.
    Given I open remote ssh connection to host '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I execute command 'echo '{"service":{"name": "confluent-kafka2"}}' > confluent-kafka2.json' in remote ssh connection
    When I execute command 'dcos package install --options=confluent-kafka2.json ${SERVICE} --yes' in remote ssh connection
    Then in less than '120' seconds, checking each '20' seconds, the command output 'dcos marathon task list' contains '/${SERVICE}2'

    #Checking service is fully up & running
    Given I want to authenticate in DCOS cluster '${DCOS_CLUSTER}' with email '${DCOS_EMAIL}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}' using pem file '${DCOS_PEM}'
    And I send requests to '${DCOS_CLUSTER}:${DCOS_CLUSTER_PORT}'
    Then in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/mesos_dns/v1/services/_broker-0._tcp.${SERVICE}2.mesos' so that the response contains '"service": "_broker-0._tcp.${SERVICE}2.mesos"'
    Then in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/mesos_dns/v1/services/_broker-1._tcp.${SERVICE}2.mesos' so that the response contains '"service": "_broker-1._tcp.${SERVICE}2.mesos"'
    Then in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/mesos_dns/v1/services/_broker-2._tcp.${SERVICE}2.mesos' so that the response contains '"service": "_broker-2._tcp.${SERVICE}2.mesos"'

    #Checking Mesos framework info
    Given I send requests to '!{mesosMaster}:${MESOS_API_PORT}'
    And I send a 'GET' request to '/frameworks'
    Then the service response status must be '200'.
    And I save element in position '0' in '$.frameworks[?(@.name == "marathon")].tasks[?(@.name == "${SERVICE}")].name' in environment variable 'name1'
    And I save element in position '0' in '$.frameworks[?(@.name == "marathon")].tasks[?(@.name == "${SERVICE}2")].name' in environment variable 'name2'
    And value stored in '!{name1}' is 'confluent-kafka'
    And value stored in '!{name2}' is 'confluent-kafka2'


  Scenario: MultiInstance-Spec-01.1 - Having two instances of the same service, each one MUST have its own resources.
    Given I open remote ssh connection to host '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    When I execute command 'dcos kafka --name ${SERVICE} topic create test' in remote ssh connection
    Then the command output contains 'Created topic'
    And I wait '1' seconds
    When I execute command 'dcos kafka --name ${SERVICE} topic list' in remote ssh connection
    Then the command output contains 'test'
    When I execute command 'dcos kafka --name ${SERVICE}2 topic list' in remote ssh connection
    Then the command output does not contain 'test'
    When I execute command 'dcos kafka --name ${SERVICE}2 topic create check' in remote ssh connection
    Then the command output contains 'Created topic'
    And I wait '1' seconds
    When I execute command 'dcos kafka --name ${SERVICE} topic list' in remote ssh connection
    Then the command output does not contain 'check'
    When I execute command 'dcos kafka --name ${SERVICE}2 topic list' in remote ssh connection
    Then the command output contains 'check'


  Scenario: Uninstall service second instance
    Given I open remote ssh connection to host '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    When I execute command 'dcos package uninstall ${SERVICE} --app-id=${SERVICE}2' in remote ssh connection
    And I execute command 'dcos marathon task list' in remote ssh connection
    Then the command output does not contain '${SERVICE}2'

    #Checking service first instance is fully up & running
    Given I want to authenticate in DCOS cluster '${DCOS_CLUSTER}' with email '${DCOS_EMAIL}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}' using pem file '${DCOS_PEM}'
    And I send requests to '${DCOS_CLUSTER}:${DCOS_CLUSTER_PORT}'
    Then in less than '120' seconds, checking each '20' seconds, I send a 'GET' request to '/mesos_dns/v1/services/_${SERVICE}._tcp.marathon.mesos' so that the response contains '"service": "_${SERVICE}._tcp.marathon.mesos"'

    Given I open remote ssh connection to host '${DCOS_CLUSTER}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}' using pem file '${DCOS_PEM}'
    When I execute command 'docker run mesosphere/janitor /janitor.py -r dcos-service-kafka2-role -p dcos-service-kafka2-principal -z dcos-service-kafka2' in remote ssh connection
    Then the command output contains 'Cleanup completed successfully.'