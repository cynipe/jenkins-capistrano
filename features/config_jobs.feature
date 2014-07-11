Feature: Configuring Jobs

  Scenario: Configuring jobs to newly created Jenkins
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
    And a file named "config/jenkins/jobs/job1.xml" with:
    """
    <?xml version="1.0" encoding="UTF-8"?><project>
      <actions/>
      <description>Created</description>
      <keepDependencies>false</keepDependencies>
      <properties/>
      <scm class="hudson.scm.NullSCM"/>
      <canRoam>true</canRoam>
      <disabled>false</disabled>
      <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
      <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
      <jdk>Default</jdk>
      <triggers/>
      <concurrentBuild>false</concurrentBuild>
      <builders/>
      <publishers/>
    </project>
    """
    When I successfully run `bundle exec cap jenkins:config_jobs`
    Then the output should contain:
      """
      job job1 created.
      """
    And the Jenkins has following jobs:
      | Name | Description | Disabled |
      | job1 | Created     | false    |

  Scenario: Configuring jobs already created
    Given the Jenkins server has following jobs:
      | Name | Description | Disabled |
      | job1 | Created     | false    |
    And a file named "Capfile" with:
    """
    require 'jenkins-capistrano'
    load 'config/deploy'
    """
    And a file named "config/deploy.rb" with:
    """
    set :jenkins_host, 'http://localhost:8080'
    """
    And a file named "config/jenkins/jobs/job1.xml" with:
    """
    <?xml version="1.0" encoding="UTF-8"?><project>
      <actions/>
      <description>Updated</description>
      <keepDependencies>false</keepDependencies>
      <properties/>
      <scm class="hudson.scm.NullSCM"/>
      <canRoam>true</canRoam>
      <disabled>false</disabled>
      <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
      <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
      <jdk>Default</jdk>
      <triggers/>
      <concurrentBuild>false</concurrentBuild>
      <builders/>
      <publishers/>
    </project>
    """
    When I successfully run `bundle exec cap jenkins:config_jobs`
    Then the Jenkins has following jobs:
      | Name | Description | Disabled |
      | job1 | Updated     | false    |
    And the output should contain:
      """
      job job1 created.
      """

  Scenario: Disabling the specified job
    Given the plain Jenkins server
    And a file named "Capfile" with:
    """
    require 'jenkins-capistrano'
    load 'config/deploy'
    """
    And a file named "config/deploy.rb" with:
    """
    set :jenkins_host, 'http://localhost:8080'
    set :disabled_jobs, %w(job1)
    """
    And a file named "config/jenkins/jobs/job1.xml" with:
    """
    <?xml version="1.0" encoding="UTF-8"?><project>
      <actions/>
      <description>Disabled</description>
      <keepDependencies>false</keepDependencies>
      <properties/>
      <scm class="hudson.scm.NullSCM"/>
      <canRoam>true</canRoam>
      <disabled>false</disabled>
      <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
      <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
      <jdk>Default</jdk>
      <triggers/>
      <concurrentBuild>false</concurrentBuild>
      <builders/>
      <publishers/>
    </project>
    """
    When I successfully run `bundle exec cap jenkins:config_jobs`
    Then the Jenkins has following jobs:
      | Name | Description | Disabled |
      | job1 | Disabled    | true     |
    And the output should contain:
      """
      job job1 created.
          -> disabled
      """

  Scenario: Configuring the jobs with teamplated config.xmls
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
    And a file named "config/jenkins/jobs/job1.xml.erb" with:
    """
    <?xml version="1.0" encoding="UTF-8"?><project>
      <actions/>
      <description><%= @templated %></description>
      <keepDependencies>false</keepDependencies>
      <properties/>
      <scm class="hudson.scm.NullSCM"/>
      <canRoam>true</canRoam>
      <disabled>false</disabled>
      <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
      <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
      <jdk>Default</jdk>
      <triggers/>
      <concurrentBuild>false</concurrentBuild>
      <builders/>
      <publishers/>
    </project>
    """
    When I successfully run `bundle exec cap jenkins:config_jobs`
    Then the Jenkins has following jobs:
      | Name | Description | Disabled |
      | job1 | Yay!!       | false    |
    And the output should contain:
      """
      job job1 created.
      """
