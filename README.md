# jenkins-capistrano

The capistrano tasks for Jenkins CI Server

## Installation

Add this line to your application's Gemfile:

    gem 'jenkins-capistrano'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jenkins-capistrano

## Example

The following code will creates or updates Jenkins jobs before each deploy task:

config directory structure(name your config.xml as a job name):

  config
  ├── deploy.rb
  └── jenkins
       └── jobs
           ├── job-name1.xml
           ├── job-name2.xml
           └── job-name3.xml


deploy.rb:

  set :application, "your-awesome-app"
  set :scm, :git
  set :repository,  "https://github.com/your/repository.git"

  set :jenkins_host, 'http://localhost:8080'
  # set :jenkins_username, '' # default empty
  # set :jenkins_password, '' # default empty
  # set :jenkins_job_config_dir, 'config/jenkins/jobs'

  before 'deploy', 'jenkins:deploy_jobs'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
