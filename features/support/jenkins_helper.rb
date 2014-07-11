require 'jenkins_api_client'
require 'nokogiri'

module JenkinsHelper

  def api
    @api ||= JenkinsApi::Client.new(
      :server_url   => 'http://localhost:8080',
      :log_location => '/dev/null'
    )
  end

  def exists?(type, name)
    return api.job.exists?(name) if type == 'job'
    api.send(type.to_s).list.include? name
  end

  def config(type, name)
    Nokogiri::XML(api.send(type.to_sym).get_config(name))
  end

  def description(type, name)
    config(type, name).xpath('//description').text
  end

  def job_disabled?(name)
    config(:job, name).xpath('//disabled').text
  end

  def jenkins_has_following_configs(type, table)
    table.hashes.each do |row|
      expect(exists?(type, row['Name'])).to eql true
      expect(description(type, row['Name'])).to eql row['Description']
      if disabled = row['Disabled'] # only for the jobs
        expect(job_disabled?(row['Name'])).to eql disabled
      end
    end
  end

  def create_job(name, description, disabled)
    api.job.create(name, <<-XML.gsub(/^ +/, ''))
      <?xml version="1.0" encoding="UTF-8"?>
      <project>
        <actions/>
        <description>#{description}</description>
        <keepDependencies>false</keepDependencies>
        <properties/>
        <scm class="hudson.scm.NullSCM"/>
        <canRoam>true</canRoam>
        <disabled>#{disabled}</disabled>
        <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
        <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
        <jdk>Default</jdk>
        <triggers/>
        <concurrentBuild>false</concurrentBuild>
        <builders/>
        <publishers/>
      </project>
    XML
  end

  def create_node(name, description)
    params =  { :name => name, :slave_host => 'dummy-by-jenkins-capistrano', :private_key_file => 'dummy' }
    api.node.create_dumb_slave(params)
    api.node.post_config(name, <<-XML.gsub(/^ +/, ''))
      <?xml version="1.0" encoding="UTF-8"?>
      <slave>
        <name>#{name}</name>
        <description>#{description}</description>
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
    XML
  end

  def create_view(name, description)
    api.view.create name
    api.view.post_config(name, <<-XML.gsub(/^ +/, ''))
      <listView>
        <name>#{name}</name>
        <description>#{description}</description>
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
    XML
  end

end
World(JenkinsHelper)
