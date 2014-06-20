set :application, 'hello'
set :repository, 'http://example.org/your/repository.git'
set :scm, :git
set :branch, 'develop'
set :deploy_via, :copy
set :deploy_to, "/opt/#{application}"
set :use_sudo, false
set :keep_releases, 5

set :stages, %w(develop staging production)
set :default_stage, 'develop'

set :user, 'vagrant'
set :password do
  ENV['DEPLOY_PASSWORD'] || Capistrano::CLI.password_prompt("linux user password[#{user}]: ")
end

# if you need the credentials
# set :jenkins_username, 'jenkins'
#set :jenkins_password do
#  ENV['DEPLOY_PASSWORD'] || Capistrano::CLI.password_prompt("jenkins server password[#{user}]: ")
#end

before 'deploy', 'deploy:check'
after  'deploy', 'jenkins:deploy_jobs'
after  'deploy', 'jenkins:deploy_jobs'
after  'deploy', 'deploy:cleanup'

depend :local, :command, 'git'
depend :remote, :directory, deploy_to
depend :remote, :writable, deploy_to
