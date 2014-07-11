Feature: Configuring Views

  Scenario: Configuring the new view
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
    And a file named "config/jenkins/views/view1.xml" with:
    """
    <listView>
      <name>view1</name>
      <description>Created</description>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
      <jobNames class="tree-set">
        <comparator class="hudson.util.CaseInsensitiveComparator" reference="../../../hudson.plugins.view.dashboard.Dashboard/jobNames/comparator"/>
      </jobNames>
      <jobFilters/>
      <columns>
        <hudson.views.StatusColumn/>
        <hudson.views.WeatherColumn/>
        <hudson.views.JobColumn/>
        <hudson.views.LastSuccessColumn/>
        <hudson.views.LastFailureColumn/>
        <hudson.views.LastDurationColumn/>
        <hudson.views.BuildButtonColumn/>
      </columns>
      <includeRegex>.*</includeRegex>
    </listView>
    """
    When I successfully run `bundle exec cap jenkins:config_views`
    Then the output should contain:
      """
      view view1 created.
      """
    And the Jenkins has following views:
      | Name  | Description |
      | view1 | Created     |

  Scenario: Configuring the view already created
    Given the Jenkins server has following views:
      | Name  | Description |
      | view1 | Created     |
    And a file named "Capfile" with:
    """
    require 'jenkins-capistrano'
    load 'config/deploy'
    """
    And a file named "config/deploy.rb" with:
    """
    set :jenkins_host, 'http://localhost:8080'
    """
    And a file named "config/jenkins/views/view1.xml" with:
    """
    <listView>
      <name>view1</name>
      <description>Updated</description>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
      <jobNames class="tree-set">
        <comparator class="hudson.util.CaseInsensitiveComparator" reference="../../../hudson.plugins.view.dashboard.Dashboard/jobNames/comparator"/>
      </jobNames>
      <jobFilters/>
      <columns>
        <hudson.views.StatusColumn/>
        <hudson.views.WeatherColumn/>
        <hudson.views.JobColumn/>
        <hudson.views.LastSuccessColumn/>
        <hudson.views.LastFailureColumn/>
        <hudson.views.LastDurationColumn/>
        <hudson.views.BuildButtonColumn/>
      </columns>
      <includeRegex>.*</includeRegex>
    </listView>
    """
    When I successfully run `bundle exec cap jenkins:config_views`
    Then the output should contain:
      """
      view view1 created.
      """
    And the Jenkins has following views:
      | Name  | Description |
      | view1 | Updated     |

  Scenario: Configuring the views with teamplated config.xmls
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
    And a file named "config/jenkins/views/view1.xml.erb" with:
    """
    <listView>
      <name>view1</name>
      <description><%= @templated %></description>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
      <jobNames class="tree-set">
        <comparator class="hudson.util.CaseInsensitiveComparator" reference="../../../hudson.plugins.view.dashboard.Dashboard/jobNames/comparator"/>
      </jobNames>
      <jobFilters/>
      <columns>
        <hudson.views.StatusColumn/>
        <hudson.views.WeatherColumn/>
        <hudson.views.JobColumn/>
        <hudson.views.LastSuccessColumn/>
        <hudson.views.LastFailureColumn/>
        <hudson.views.LastDurationColumn/>
        <hudson.views.BuildButtonColumn/>
      </columns>
      <includeRegex>.*</includeRegex>
    </listView>
    """
    When I successfully run `bundle exec cap jenkins:config_views`
    Then the Jenkins has following views:
      | Name  | Description |
      | view1 | Yay!!       |
    And the output should contain:
      """
      view view1 created.
      """
