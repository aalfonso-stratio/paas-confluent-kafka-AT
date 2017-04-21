@rest
Feature: High Availability and Fault Tolerance testing

  Background: Setup PaaS REST client
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    Then I obtain mesos master in cluster '${DCOS_IP}' and store it in environment variable 'mesosMaster'
    And I send requests to '!{mesosMaster}:${MESOS_API_PORT}'

  Scenario: [HA-Spec-01] Scheduler MUST register with a failover timeout
    Given I send a 'GET' request to '/frameworks'
    Then the service response status must be '200'.
    And I save element in position '0' in '$.frameworks[?(@.name == "confluent-kafka-sec")].failover_timeout' in environment variable 'failoverTimeout'
    And value stored in '!{failoverTimeout}' is higher than '0'

  Scenario: [HA-Spec-02] and [HA-Spec-03] - Scheduler MUST persist their FrameworkID for failover and Scheduler MUST recover from process termination
    # Try to obtain hostname where service scheduler is running
    # 1 - Obtain all service frameworks
    Given I send a 'GET' request to '/frameworks'
    Then the service response status must be '200'.
    And I save element '$.frameworks[?(@.name == "confluent-kafka-sec")]' in environment variable 'serviceFrameworks'
    # 2 - Obtain hostname from array of frameworks
    Given I obtain hostname where 'scheduler' is running and id from '!{serviceFrameworks}' and store it in 'frameworkHostname' and 'frameworkId'
    # Kill scheduler task in hostname
    Then I kill 'confluent-kafka-sec' 'scheduler task' in hostname '!{frameworkHostname}'
    And I wait '20' seconds
    # Check that scheduler is re-launched
    Given I send a 'GET' request to '/frameworks'
    Then the service response status must be '200'.
    And I save element '$.frameworks[?(@.name == "confluent-kafka-sec")]' in environment variable 'serviceFrameworks2'
    Given I obtain hostname where 'scheduler' is running and id from '!{serviceFrameworks2}' and store it in 'frameworkHostname2' and 'frameworkId2'
    # FrameworkId should be the same
    Then value stored in '!{frameworkId}' is '!{frameworkId2}'

  Scenario: [HA-Spec-04] - Scheduler MUST enable checkpointing
    Given I send a 'GET' request to '/frameworks'
    Then the service response status must be '200'.
    And I save element in position '0' in '$.frameworks[?(@.name == "confluent-kafka-sec")].checkpoint' in environment variable 'checkpoint'
    And value stored in '!{checkpoint}' is 'true'

  #Scenario: [HA-Spec-05] - Scheduler MUST reconcile tasks during failover

  @ignore @tillfixed(PAAS-1294)
  Scenario: [HA-Spec-06] - Scheduler MUST use a reliable store for persistent state
    # Obtain framework id through Mesos API
    Given I send a 'GET' request to '/frameworks'
    Then the service response status must be '200'.
    And I save element in position '0' in '$.frameworks[?(@.name == "confluent-kafka-sec")].id' in environment variable 'FrameworkIDMesos'
    # Get framework id stored in Zookeeper
    # 1 - Obtain user and password
    # Given I obtain mesos API user and password in '${DCOS_CLUSTER}'
    # 2 - Obtain framework id
    Given I send requests to '${DCOS_IP}:${EXHIBITOR_API_PORT}'
    When I send a 'POST' request to '/exhibitor/v1/explorer/analyze' based on 'schemas/frameworkID' as 'json' with:
      | max | UPDATE | 0 |
      | path | UPDATE | /dcos-service-confluent-kafka-sec/FrameworkID |
    Then the service response status must be '200' and its response must contain the text 'childIds'
    And I save element in position '0' in '$.nodes[0].childIds' in environment variable 'FrameworkIDZK'
    And I sanitize environment variable 'FrameworkIDZK'
    # Compare values
    And value stored in '!{FrameworkIDMesos}' is '!{FrameworkIDZK}'
