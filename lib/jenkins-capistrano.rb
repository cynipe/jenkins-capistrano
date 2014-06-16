require 'jenkins-capistrano/version'
require 'jenkins_api_client'

def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

# Capistrano task for Jenkins.
#
# Just add "require 'jenkins-capistrano'" in your Capistrano deploy.rb
Capistrano::Configuration.instance(:must_exist).load do

  _cset(:jenkins_host) { abort "Please specify the host of your jenkins server, set :jenkins_host, 'http://localhost:8080'" }

  _cset(:jenkins_username) { '' }
  _cset(:jenkins_password) { '' }

  _cset(:jenkins_job_config_dir) { 'config/jenkins/jobs' }
  _cset(:jenkins_node_config_dir) { 'config/jenkins/nodes' }
  _cset(:jenkins_view_config_dir) { 'config/jenkins/views' }

  _cset(:disabled_jobs) { [] }

  def client
    @client ||= JenkinsApi::Client.new(
      :log_location => '/dev/null',
      :server_url   => jenkins_host,
      :username     => jenkins_username,
      :password     => jenkins_password
    )
  end

  def job_configs
    abort "Please create the jenkins_job_config_dir first: #{jenkins_job_config_dir}" unless Dir.exists? jenkins_job_config_dir
    Dir.glob("#{jenkins_job_config_dir}/*.xml")
  end

  def node_configs
    abort "Please create the jenkins_node_config_dir first: #{jenkins_node_config_dir}" unless Dir.exists? jenkins_node_config_dir
    Dir.glob("#{jenkins_node_config_dir}/*.json")
  end

  def view_configs
    abort "Please create the jenkins_view_config_dir first: #{jenkins_node_config_dir}" unless Dir.exists? jenkins_node_config_dir
    Dir.glob("#{jenkins_view_config_dir}/*.xml")
  end

  def name_for(file_path)
    file_path.basename.to_s.split('.').first
  end

  # minimum configurations
  #
  #   role :jenkins, 'localhost:8080'
  namespace :jenkins do

    desc <<-DESC
      Deploy the jobs to Jenkins server -- meaning create or update --

      Configuration
      -------------
      jenkins_job_config_dir
          the directory path where the config.xml stored.
          default: 'config/jenkins/jobs'

      disabled_jobs
          job names array which should be disabled after deployment.
          default: []

    DESC
    task :deploy_jobs do
      logger.info "deploying jenkins jobs to #{jenkins_host}"
      logger.important "no job configs found." if job_configs.empty?
      job_configs.each do |file|
        name = File.basename(file, '.xml')
        msg = StringIO.new

        client.job.create_or_update(name, File.read(file))
        msg << "job #{name} created"

        if disabled_jobs.include? name
          client.job.disable(name)
          msg << ", but was set to disabled"
        end
        msg << "."
        logger.trace msg.string
      end
    end

    desc <<-DESC
      Configure the nodes to Jenkins server -- meaning create or update --

      Configuration
      -------------
      jenkins_node_config_dir
          the directory path where the node's configuration stored.
          default: 'config/jenkins/nodes'
    DESC
    task :config_nodes do
      logger.info "configuring jenkins nodes to #{jenkins_host}"
      logger.important "no node configs found." if node_configs.empty?
      node_configs.each do |file|
        name = File.basename(file, '.xml')
        unless client.node.list.include? name
          params =  { :name => name, :slave_host => 'dummy-by-jenkins-capistrano', :private_key_file => 'dummy' }
          client.node.create_dumb_slave(params)
        end
        client.node.post_config(name, File.read(file))
        logger.trace "node #{name} created."
      end
    end

    desc <<-DESC
      Configure the views to Jenkins server -- meaning create or update --

      Configuration
      -------------
      jenkins_view_config_dir
          the directory path where the view's configuration stored.
          default: 'config/jenkins/views'
    DESC
    task :config_views do
      logger.info "configuring jenkins views to #{jenkins_host}"
      logger.important "no view configs found." if view_configs.empty?
      view_configs.each do |file|
        name = File.basename(file, '.xml')
        unless client.view.exists? name
          client.view.create name
        end
        client.view.post_config(name, File.read(file))
        logger.trace "view #{name} created."
      end
    end

  end

end
