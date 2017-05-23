@rest @web
Feature: Scale brokers and users in confluent-kafka-sec

  # Scale brokers
  Scenario: Install instance of confluent-kafka-sec
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/confluent-kafka-sec.json' as 'json' with:
      | $.id | UPDATE | confluent-kafka-sec |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | ${VAULT_TOKEN} |
      | $.env.FRAMEWORK_NAME| UPDATE | confluent-kafka-sec |
      | $.labels.DCOS_SERVICE_NAME | UPDATE | confluent-kafka-sec |
      | $.labels.DCOS_PACKAGE_FRAMEWORK_NAME | UPDATE | confluent-kafka-sec |
    Then the service response status must be '201'.
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w confluent-kafka-sec | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep broker | wc -l' contains '3'

  Scenario: Login and modify BROKER_COUNT through GUI
    Given My app is running in 'gosec2.node.paas.labs.stratio.com:9005'
    And I securely browse to '/gosec-sso/login'
    And I wait '2' seconds
    Then '1' element exists with 'id:username'
    And I type 'admin' on the element on index '0'
    And '1' element exists with 'id:password'
    And I type '1234' on the element on index '0'
    And '1' element exists with 'css:input[data-qa="login-button-submit"]'
    When I click on the element on index '0'
    Then '1' element exists with 'css:div[class="login__success-text1"]'

    Given My app is running in 'master-1.node.paas.labs.stratio.com:443'
    And I securely browse to '/'
    And I wait '2' seconds
    And I securely browse to '/#/services/%2Fconfluent-kafka-sec/'
    And I wait '2' seconds
    And I securely browse to '/#/services/%2Fconfluent-kafka-sec/'
    And I wait '2' seconds
    Then '1' element exists with 'xpath://*[@id="canvas"]/div[2]/div[2]/div[3]/div/div/div/div/div[1]/div/div[1]/div[2]/div/button[2]'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath:/html/body/div[13]/div/div[2]/div/div/div[2]/div/div/div[3]/div/div/div/div[1]/div/ul/li[4]/a'
    When I click on the element on index '0'
    And I wait '2' seconds
    Then '1' element exists with 'xpath:/html/body/div[13]/div/div[2]/div/div/div[2]/div/div/div[3]/div/div/div/div[2]/div[3]/div[4]/form/div[1]/h2'
    And '1' element exists with 'css:input[value="BROKER_COUNT"]'
    And '1' element exists with 'xpath:/html/body/div[13]/div/div[2]/div/div/div[2]/div/div/div[3]/div/div/div/div[2]/div[3]/div[4]/form/div[17]/div[2]/div/input'
    And I clear the content on text input at index '0'
    And I type '4' on the element on index '0'
    Given '1' element exists with 'css:button[class="button button-large flush-bottom button-success"]'
    Then I click on the element on index '0'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_USER}' and password '${DCOS_PASSWORD}'
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w confluent-kafka-sec | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep broker | wc -l' contains '4'
