@rest
Feature: Installing / uninstalling testing with ${SERVICE}

  Background: Setup PaaS REST client
  Given I open remote ssh connection to host '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'

  Scenario: InstallUninstall-Spec-01. A service CAN be installed from the CLI
    When I execute command 'dcos package install ${SERVICE} --yes' in remote ssh connection
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep ${SERVICE} | grep R | wc -l' contains '1'
    Then in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep broker | grep R | wc -l' contains '3'
