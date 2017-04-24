@rest
Feature: Service discovery testing

  Scenario: ServiceDiscovery-Spec-01 - Mesos-DNS MUST create the service
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    #Then I securely check service 'confluent-kafka-sec' is registered in master '${MASTER_HOSTNAME}' in mesos_dns
    And I securely send requests to '${MASTER_HOSTNAME}'
    Then in less than '120' seconds, checking each '20' seconds, I send a 'GET' request to '/mesos_dns/v1/services/_confluent-kafka-sec._tcp.marathon.mesos' so that the response contains '"service": "_confluent-kafka-sec._tcp.marathon.mesos"'
