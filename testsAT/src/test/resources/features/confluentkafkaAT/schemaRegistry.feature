@rest
Feature: Producing/consuming data using schema registry

  Scenario: Install schema-registry-sec
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/schema-registry-sec.json' as 'json' with:
      | $.env.VAULT_HOSTS | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | ${VAULT_TOKEN} |
    Then the service response status must be '201'.
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w schema-registry-sec | wc -l' contains '1'
    Given I run 'dcos marathon task list schema-registry-sec | awk '{print $5}' | grep schema-registry-sec' in the ssh connection and save the value in environment variable 'marathonTaskId'
    #DCOS dcos marathon task show check healtcheck status
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep healthCheckResults | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep '"alive": true' | wc -l' contains '1'

  Scenario: Launch producer
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    # Obtain broker-0 host
    Then I run 'dcos task | grep broker-0 | awk '{print $2}'' in the ssh connection and save the value in environment variable 'broker0Host'
    # Obtain schema-registry-sec port
    And I run 'dcos marathon app show schema-registry-sec | jq '.tasks[0].ports[0]'' in the ssh connection with exit status '0' and save the value in environment variable 'schemaRegistryPort'

    # Obtain broker-0 port
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    When I securely send requests to '${DCOS_IP}:443'
    And I send a 'GET' request to '/mesos_dns/v1/services/_broker-0._tcp.confluent-kafka-sec.mesos'
    Then I save element '$.[0].port' in environment variable 'broker0Port'

    # Log to broker-0
    Given I open a ssh connection to '!{broker0Host}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    # Obtain sandbox directory
    Then I run 'ps -ef | grep java | grep kafka_confluent-oss  | awk '{print $8;}' | awk -F'/jre' '{print $1}'' in the ssh connection and save the value in environment variable 'sandboxDirectory'
    # Go to sandbox directory
    And I run 'cd !{sandboxDirectory}/kafka_confluent-oss-3.1.1/bin' in the ssh connection
    # Create topic
    And I run './kafka-topics --create --topic ${SCHEMA_TOPIC} --partitions 1 --replication-factor 1 --zookeeper master.mesos:2181/dcos-service-confluent-kafka-sec' in the ssh connection with exit status '0'
    # Export security options for avro console and producer
    And I run 'export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.keyStore=!{sandboxDirectory}/broker-0-confluent-kafka-sec.jks -Djavax.net.ssl.keyStoreType=JKS -Djavax.net.ssl.keyStorePassword=br0k3r_0_c0nflu3nt_k4fk4_s3c -Djavax.net.ssl.trustStore=!{sandboxDirectory}/truststore.jks -Djavax.net.ssl.trustStoreType=JKS -Djavax.net.ssl.trustStorePassword=c4_trust_d3f4ult_k3yst0r3"' in the ssh connection with exit status '0'
    # Define DEFAULT_SCHEMA_REGISTRY_URL
    And I run 'export DEFAULT_SCHEMA_REGISTRY_URL="--property schema.registry.url=https://schema-registry-sec.marathon.mesos:!{schemaRegistryPort}"' in the ssh connection with exit status '0'
    # Produce messages
    When I run './kafka-avro-console-producer.sh --topic ${SCHEMA_TOPIC} --producer.config ../config/producer.properties --broker-list broker-0.confluent-kafka-sec.mesos:!{broker0Port} --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}'' in the ssh connection

#  Scenario: Launch consumer
#    # Log to broker-0
#    Given I open a ssh connection to '!{broker0Host}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}' using pem file '${PEM_FILE}'
#    # Consume messages
#    When I run './kafka-avro-console-consumer.sh --topic ${SCHEMA_TOPIC} --bootstrap-server broker-0.confluent-kafka-sec.mesos:!{broker0Port}  --consumer.config=../config/consumer.properties' in the ssh connection
