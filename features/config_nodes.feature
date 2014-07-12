Feature: Configuring Nodes

  Scenario: Configuring the new node
    Given the plain Jenkins server
    And a file named "Capfile" with:
    """
    require 'jenkins-capistrano'
    load 'config/deploy'
    """
    And a file named "config/deploy.rb" with:
    """
    set :jenkins_host, 'http://localhost:8080'
    """
    And a file named "config/jenkins/nodes/node1.xml" with:
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <slave>
      <name>node1</name>
      <description>Created</description>
      <remoteFS>/home/jenkins</remoteFS>
      <numExecutors>5</numExecutors>
      <mode>EXCLUSIVE</mode>
      <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
      <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
        <host>node1.lan</host>
        <port>22</port>
        <credentialsId>credential</credentialsId>
      </launcher>
      <label/>
      <nodeProperties/>
    </slave>
    """
    When I successfully run `bundle exec cap jenkins:config_nodes`
    Then the output should contain:
      """
      node node1 created.
      """
    And the Jenkins has following nodes:
      | Name  | Description |
      | node1 | Created     |

  Scenario: Configuring the node already created
    Given the Jenkins server has following nodes:
      | Name  | Description |
      | node1 | Created     |
    And a file named "Capfile" with:
    """
    require 'jenkins-capistrano'
    load 'config/deploy'
    """
    And a file named "config/deploy.rb" with:
    """
    set :jenkins_host, 'http://localhost:8080'
    """
    And a file named "config/jenkins/nodes/node1.xml" with:
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <slave>
      <name>node1</name>
      <description>Updated</description>
      <remoteFS>/home/jenkins</remoteFS>
      <numExecutors>5</numExecutors>
      <mode>EXCLUSIVE</mode>
      <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
      <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
        <host>node1.lan</host>
        <port>22</port>
        <credentialsId>credential</credentialsId>
      </launcher>
      <label/>
      <nodeProperties/>
    </slave>
    """
    When I successfully run `bundle exec cap jenkins:config_nodes`
    Then the output should contain:
      """
      node node1 created.
      """
    And the Jenkins has following nodes:
      | Name  | Description |
      | node1 | Updated     |

  Scenario: Configuring the nodes with teamplated config.xmls
    Given the plain Jenkins server
    And a file named "Capfile" with:
    """
    require 'jenkins-capistrano'
    load 'config/deploy'
    """
    And a file named "config/deploy.rb" with:
    """
    set :jenkins_host, 'http://localhost:8080'
    set :jenkins_template_vars, { :templated => 'Yay!!' }
    """
    And a file named "config/jenkins/nodes/node1.xml.erb" with:
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <slave>
      <name>node1</name>
      <description><%= @templated %></description>
      <remoteFS>/home/jenkins</remoteFS>
      <numExecutors>5</numExecutors>
      <mode>EXCLUSIVE</mode>
      <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
      <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
        <host>node1.lan</host>
        <port>22</port>
        <credentialsId>credential</credentialsId>
      </launcher>
      <label/>
      <nodeProperties/>
    </slave>
    """
    When I successfully run `bundle exec cap jenkins:config_nodes`
    Then the Jenkins has following nodes:
      | Name  | Description |
      | node1 | Yay!!       |
    And the output should contain:
      """
      node node1 created.
      """

  Scenario: Configuring the node with Json
    Given the plain Jenkins server
    And a file named "Capfile" with:
      """
      require 'jenkins-capistrano'
      load 'config/deploy'
      """
    And a file named "config/deploy.rb" with:
      """
      set :jenkins_host, 'http://localhost:8080'
      """
    And a file named "config/jenkins/nodes/node1.json" with:
      """
      {
        "description" : "Slave1",
        "slave_fs"    : "/home/jenkins",
        "executors"   : 5,
        "exclusive"   : true,
        "labels"      : "hello",
        "slave_host"  : "dev-slave01.local",
        "slave_port"  : 22,
        "slave_user"  : "jenkins",
        "master_key"  : "/var/lib/jenkins/.ssh/id_rsa",
        "jvm_options" : "-Dfile.encoding=UTF-8",
        "env_vars": {
          "LANG"            : "ja_JP.UTF-8",
          "ENVIRONMENT"     : "production",
        }
      }
      """
    When I run `bundle exec cap jenkins:config_nodes`
    Then the exit status should be 1
    And the output should contain:
      """
      Configuring the node using json is not supported anymore, use config.xml instead.
      You could get the node's config.xml from a running Jenkins with following command:

      $ curl -o config/jenkins/nodes/<node_name>.xml http://<jenkins-host>/computer/<node_name>/config.xml
      """
