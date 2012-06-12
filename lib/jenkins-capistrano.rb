require 'jenkins-capistrano/version'
require 'jenkins-capistrano/client'

def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

# Capistrano task for Jenkins.
#
# Just add "require 'jenkins-capistrano'" in your Capistrano deploy.rb, and
Capistrano::Configuration.instance(:must_exist).load do

  _cset(:jenkins_host) { abort "Please specify the host of your jenkins server, set :jenkins_host, 'http://localhost:8080'" }

  _cset(:jenkins_username) { '' }
  _cset(:jenkins_password) { '' }

  _cset(:jenkins_job_config_dir) { 'config/jenkins/jobs' }

  def client
    @client ||= Jenkins::Client.new(jenkins_host, { :username => jenkins_username,  :password => jenkins_password})
  end

  def job_configs
    Dir.glob("#{jenkins_job_config_dir}/*.xml")
  end

  # minimum configurations
  #
  #   role :jenkins, 'localhost:8080'
  namespace :jenkins do

    desc <<-DESC
    Deploy the jobs to Jenkins server -- meaning create or update --

      set :jenkins_job_config_dir,      'config/jenkins/jobs'
      set :jenkins_job_deploy_strategy, :clean | :merge
    DESC
    task :deploy_jobs do
      strategy = fetch(:jenkins_job_deploy_strategy, :clean)
      logger.info "deploying jenkins jobs to #{jenkins_host}"
      logger.warn "no job configs found." if job_configs.empty?
      job_configs.each do |file|
        name = File.basename(file, '.xml')
        client.create_or_update_job(name, File.read(file))
        logger.trace "job #{name} created."
      end

    end

  end

end
