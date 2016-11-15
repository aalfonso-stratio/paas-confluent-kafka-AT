Feature: Purge process after testing a framework

  Background: Connection to CLI
    Given I open remote ssh connection to host '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'

  Scenario: InstallUninstall-Spec-02. A service CAN be uninstalled from the CLI
    Given I execute command 'dcos package uninstall ${SERVICE}' in remote ssh connection
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep ${SERVICE} | wc -l' contains '0'

    And I open remote ssh connection to host '${DCOS_CLUSTER}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}' using pem file '${DCOS_PEM}'
    When I execute command 'docker run mesosphere/janitor /janitor.py -r ${SERVICE}-role -p ${SERVICE}-principal -z dcos-service-${SERVICE}' in remote ssh connection
    Then the command output contains 'Successfully deleted znode 'dcos-service-confluent-kafka' (code=200)'
