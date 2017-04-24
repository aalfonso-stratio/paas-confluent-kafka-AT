@rest
Feature: Functionality
  Background:
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I connect to kafka at '${DCOS_IP}:${DCOS_ZK_PORT}' using path 'dcos-service-confluent-kafka-sec'

  Scenario: [Kafka-Functional-Spec-01] - Create topic
    When I create a Kafka topic named '${KAFKA_TOPIC}1'
    Then A kafka topic named '${KAFKA_TOPIC}1' exists

  Scenario: [Kafka-Functional-Spec-02] - Create and delete topic with enable.delete.topic = false
    When I create a Kafka topic named '${KAFKA_TOPIC}2'
    When I delete a Kafka topic named '${KAFKA_TOPIC}2'
    Then A kafka topic named '${KAFKA_TOPIC}2' exists

  Scenario: [Kafka-Functional-Spec-02] - Change enable.delete.topic config create topic and delete topic
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}' using pem file '${PEM_FILE}'
    When I modify marathon environment variable '$.env.KAFKA_OVERRIDE_DELETE_TOPIC_ENABLE' with value 'true' for service 'confluent-kafka-sec'
    When I create a Kafka topic named '${KAFKA_TOPIC}3'
    Then in less than '360' seconds, checking each '20' seconds, the command output 'dcos task | grep confluent-kafka-sec | grep R | wc -l' contains '1'
    When I delete a Kafka topic named '${KAFKA_TOPIC}3'
    Then A kafka topic named '${KAFKA_TOPIC}3' not exists

  Scenario: [Kafka-Functional-Spec-03] - Modify topic partitioning
    When I create a Kafka topic named '${KAFKA_TOPIC}4'
    When I increase '${NUM_PARTITIONS}' partitions in a Kafka topic named '${KAFKA_TOPIC}4'
    Then The number of partitions in topic '${KAFKA_TOPIC}4' should be '${NUM_PARTITIONS}''