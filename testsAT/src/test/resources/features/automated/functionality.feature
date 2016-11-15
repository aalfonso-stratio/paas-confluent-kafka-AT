@rest
Feature: Fuctionality
  Background:
    Given I want to authenticate in DCOS cluster '${DCOS_CLUSTER}' with email '${DCOS_EMAIL}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}' using pem file '${DCOS_PEM}'
    And I connect to kafka cluster at '${DCOS_CLUSTER}':'${DCOS_ZK_PORT}' using path '${SERVICE}'
    Given I open remote ssh connection to host '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}' using pem file '${DCOS_PEM}'

  Scenario: [Kafka-Functional-Spec-01] - Create topic
    When I create a Kafka topic named '${KAFKA_TOPIC}1'
    Then A kafka topic named '${KAFKA_TOPIC}1' exists

  Scenario: [Kafka-Functional-Spec-02] - Create and delete topic with enable.delete.topic = false
    When I create a Kafka topic named '${KAFKA_TOPIC}2'
    When I delete a Kafka topic named '${KAFKA_TOPIC}2'
    Then A kafka topic named '${KAFKA_TOPIC}2' exists

  Scenario: [Kafka-Functional-Spec-02] - Change enable.delete.topic config create topic and delete topic
    When I modify the enviroment variable '$.env.KAFKA_OVERRIDE_DELETE_TOPIC_ENABLE' with value 'true' in service '${SERVICE}'
    When I create a Kafka topic named '${KAFKA_TOPIC}3'
    Then in less than '200' seconds, checking each '20' seconds, the command output 'dcos task | grep ${SERVICE} | grep S | wc -l' contains '1'
    Then in less than '360' seconds, checking each '20' seconds, the command output 'dcos task | grep ${SERVICE} | grep R | wc -l' contains '1'

    When I delete a Kafka topic named '${KAFKA_TOPIC}3'
    Then A kafka topic named '${KAFKA_TOPIC}3' not exists

  Scenario: [Kafka-Functional-Spec-03] - Modify topic partitioning
    When I create a Kafka topic named '${KAFKA_TOPIC}4'
    When I increase '${NUM_PARTITIONS}' partitions in a Kafka topic named '${KAFKA_TOPIC}4'
    Then The number of partitions in topic '${KAFKA_TOPIC}4' should be '${NUM_PARTITIONS}''