Feature: Purge process after testing a framework

  Scenario: InstallUninstall-Spec-02. A service CAN be uninstalled from the CLI
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    When I run 'dcos package uninstall confluent-kafka-sec' in the ssh connection
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep confluent-kafka-sec | wc -l' contains '0'
    When I run 'dcos marathon task list' in the ssh connection
    Then the command output does not contain 'confluent-kafka-sec'