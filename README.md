# README

## ACCEPTANCE TESTS

Cucumber automated acceptance tests for Confluent kafka running under Stratio PaaS.
This module depends on a QA library (stratio-test-bdd), where common logic and steps are implemented.

## EXECUTION

These tests will be executed as part of the continuous integration flow as follows:

mvn verify [-D\<ENV_VAR>=\<VALUE>] [-Dit.test=\<TEST_TO_EXECUTE>|-Dgroups=\<GROUP_TO_EXECUTE>]

Example:

mvn verify -DDCOS_IP=10.200.1.11 -DDCOS_CLI_HOST=dcos-cli-11.ali.com -DMESOS_API_PORT=5050 -DDCOS_USER=root -DDCOS_PASSWORD=stratio -DDCOS_EMAIL=qatest@stratio.com -DEXHIBITOR_API_PORT=8181 -DDCOS_ZK_PORT=2181 -DSERVICE_ZK_PORT=31886 -DDCOS_PEM=none -DPSQL_HOST=paaspostgresbd.labs.stratio.com -DPSQL_PORT=5432  -DPSQL_DB=services -DDCOS_CLUSTER_PORT=80 -DSERVICE=confluent-kafka -Dgroups=confluent-kafka-installation2 -Dmaven.failsafe.debug

- installation
mvn verify -DDCOS_IP=10.200.0.46 -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DDCOS_USER=root -DDCOS_PASSWORD=stratio -DPEM_FILE=none -DREMOTE_USER=root -DREMOTE_PASSWORD=stratio -DVAULT_HOST=gosec2.node.paas.labs.stratio.com -DVAULT_PORT=8200 -DVAULT_TOKEN=906cfbe3-7567-0c92-e1bd-c1d77eb9f460 -Dgroups=installation

- configuration
mvn verify -DDCOS_IP=10.200.0.46 -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DMESOS_API_PORT=5050 -DDCOS_USER=root -DDCOS_PASSWORD=stratio -Dgroups=configuration

- functionality
mvn verify -U -Dgroups=functionality -DDCOS_IP=10.200.0.46 -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DMESOS_API_PORT=5050 -DDCOS_USER=root -DDCOS_PASSWORD=stratio -DPEM_FILE=none -DKAFKA_TOPIC=alftopic -DDCOS_ZK_PORT=2181 -DREMOTE_USER=root -DREMOTE_PASSWORD=stratio -DNUM_PARTITIONS=3

- service discovery
mvn verify -Dgroups=serviceDiscovery -DDCOS_IP=10.200.0.46 -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DDCOS_USER=root -DDCOS_PASSWORD=stratio -DDCOS_CLUSTER_PORT=80 -DREMOTE_USER=root -DREMOTE_PASSWORD=stratio -DMASTER_HOSTNAME=master-1.node.paas.labs.stratio.com

- multi-instance
mvn verify -Dgroups=multi_instance -DDCOS_IP=10.200.0.46 -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DDCOS_USER=root -DDCOS_PASSWORD=stratio -DDCOS_CLUSTER_PORT=80 -DREMOTE_USER=root -DREMOTE_PASSWORD=stratio -DMASTER_HOSTNAME=master-1.node.paas.labs.stratio.com -DVAULT_HOST=gosec2.node.paas.labs.stratio.com -DVAULT_PORT=8200 -DVAULT_TOKEN=906cfbe3-7567-0c92-e1bd-c1d77eb9f460 -DMESOS_API_PORT=5050

- haft
mvn verify -Dgroups=haft -DDCOS_IP=10.200.0.46 -DDCOS_CLI_HOST=dcos-cli.demo.labs.stratio.com -DDCOS_USER=root -DDCOS_PASSWORD=stratio -DDCOS_CLUSTER_PORT=80 -DREMOTE_USER=root -DREMOTE_PASSWORD=stratio -DMESOS_API_PORT=5050 -DEXHIBITOR_API_PORT=8181

By default, in jenkins we will execute the group confluent, which should contain a subset of tests, that are key to the functioning of the module and the ones generated for the new feature.

All tests, that are not fully implemented, should be tagged with '@ignore @tillfixed(PAAS-XXX)'
