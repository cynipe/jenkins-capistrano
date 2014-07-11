Feature: Help

  Scenario: Show help for all tasks
    Given a file named "Capfile" with:
      """
      require 'jenkins-capistrano'
      """
    When I successfully run `bundle exec cap -T`
    Then the output should contain:
      """
      cap invoke               # Invoke a single command on the remote servers.
      cap jenkins:config_jobs  # Configure the jobs to Jenkins server.
      cap jenkins:config_nodes # Configure the nodes to Jenkins server.
      cap jenkins:config_views # Configure the views to Jenkins server.
      cap jenkins:deploy_jobs  # [DEPRECATED] Use jenkins:config_jobs instead.
      cap shell                # Begin an interactive Capistrano session.
      """

  Scenario: Show help for config_jobs
    Given a file named "Capfile" with:
      """
      require 'jenkins-capistrano'
      """
    When I successfully run `bundle exec cap -e jenkins:config_jobs`
    Then the output should contain:
      """
      Configure the jobs to Jenkins server.

      Configuration
      -------------
      jenkins_job_config_dir
          the directory path where the config.xml stored.
          default: 'config/jenkins/jobs'

      disabled_jobs
          job names array which should be disabled after deployment.
          default: []
      """

  Scenario: Show help for config_jobs
    Given a file named "Capfile" with:
      """
      require 'jenkins-capistrano'
      """
    When I successfully run `bundle exec cap -e jenkins:deploy_jobs`
    Then the output should contain:
      """
      [DEPRECATED] Use jenkins:config_jobs instead.
      """

  Scenario: Show help for config_nodes
    Given a file named "Capfile" with:
      """
      require 'jenkins-capistrano'
      """
    When I successfully run `bundle exec cap -e jenkins:config_nodes`
    Then the output should contain:
      """
      Configure the nodes to Jenkins server.

      Configuration
      -------------
      jenkins_node_config_dir
          the directory path where the node's configuration stored.
          default: 'config/jenkins/nodes'
      """

  Scenario: Show help for config_views
    Given a file named "Capfile" with:
      """
      require 'jenkins-capistrano'
      """
    When I successfully run `bundle exec cap -e jenkins:config_views`
    Then the output should contain:
      """
      Configure the views to Jenkins server.

      Configuration
      -------------
      jenkins_view_config_dir
          the directory path where the view's configuration stored.
          default: 'config/jenkins/views'
      """
