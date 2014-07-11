# jenkins-capistrano

**Note**: 0.1.0 has incompatible change for Node creation.
see [Release Notes](#release-notes) and [Node Configuration](#node-configuration) for detail.

#### Table of Contents

1. [Overview](#overview)
1. [Installation](#installation)
1. [Usage](#usage)
  * [Job Configuration](#job-configuration)
    * [Disabling Jobs](#disabling-jobs)
  * [Node Configuration](#node-configuraton)
    * [Note for the Credentials Plugin and multistage-extension]()
  * [View Configuration](#view-configuraton)
1. [Don't know how to write config.xml?](#dont-know-how-to-write-configxml)
1. [Known Issues](#known-issues)
  * [Using mutlibyte characters in config.xml](#using-multibyte-characters-in-configxml)
1. [Todo](#todo)
1. [Release Notes](#release-notes)
1. [Contributing](#contributing)

## Overview

The capistrano tasks for Jenkins CI Server which manages following things:

* Job
* Node
* View

## Installation

Add this line to your application's Gemfile::

```
gem 'jenkins-capistrano'
```

And then execute::

```
$ bundle
```

Or install it yourself as::

```
$ gem install jenkins-capistrano
```

## Usage

See example directory or following instructions.

### Job Configuration

The following code will creates or updates Jenkins jobs before each deploy task:

config directory structure(name your config.xml as a job name):
```
config
├── deploy.rb
└── jenkins
     └── jobs
         ├── job-name1.xml
         ├── job-name2.xml
         └── job-name3.xml
```

deploy.rb:
```ruby
set :application, "your-awesome-app"
set :scm, :git
set :repository,  "https://github.com/your/repository.git"

set :jenkins_host, 'http://localhost:8080'
#set :jenkins_username, '' # default empty
#set :jenkins_password, '' # default empty
#set :jenkins_job_config_dir, 'config/jenkins/jobs'

before 'deploy', 'jenkins:deploy_jobs'
```

#### Disabling Jobs

Since 0.0.5, you can disabling jobs using `disabled_jobs` option.
Use this option with [multistage-extension](<https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension>).

Put the following line into `config/deploy/<env>.rb`:
```
set :disabled_jobs, %w(job1 job2)
```

### Node Configuration

config directory structure(name your json file as a node name):
```
config
├── deploy.rb
└── jenkins
     └── nodes
         ├── node1.xml
         ├── node2.xml
         └── node3.xml
```

sample node configuration:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>example</name>
  <description/>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>5</numExecutors>
  <mode>EXCLUSIVE</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
    <host>dev-slave01.local</host>
    <port>22</port>
    <credentialsId>CREDENTIAL-ID-FOR-SLAVE</credentialsId>
    <jvmOptions>-Dfile.encoding=UTF-8</jvmOptions>
  </launcher>
  <label>hello</label>
  <nodeProperties>
    <hudson.slaves.EnvironmentVariablesNodeProperty>
      <envVars serialization="custom">
        <unserializable-parents/>
        <tree-map>
          <default>
            <comparator class="hudson.util.CaseInsensitiveComparator"/>
          </default>
          <int>2</int><!-- must specify env var count -->
          <string>LANG</string>
          <string>ja_JP.UTF-8</string>
          <string>ENVIRONMENT</string>
          <string>develop</string>
        </tree-map>
      </envVars>
    </hudson.slaves.EnvironmentVariablesNodeProperty>
  </nodeProperties>
</slave>
```

deploy.rb:
```ruby
set :application, "your-awesome-app"
set :scm, :git
set :repository,  "https://github.com/your/repository.git"

set :jenkins_host, 'http://localhost:8080'
# set :jenkins_username, '' # default empty
# set :jenkins_password, '' # default empty
# set :jenkins_node_config_dir, 'config/jenkins/nodes'

before 'deploy', 'jenkins:config_nodes'
```

#### Note for the Credentials Plugin and multistage-extension

Recently, Jenkins has changed the slave's auth method to use
[Credentials Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Credentials+Plugin),
and we need to use its id(credentialsId) to create slave configuration.
However, Credentials Plugin doesn't have a REST interface to manage their credentials,
and credentialsId is different on every Jenkins master.

So, if you want to use same config.xml against different masters,
use the ERB template support to specify correct credentialsId like as following:

config/jenkins/nodes/node1.xml.erb:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>batch-slave</name>
  <description/>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>5</numExecutors>
  <mode>EXCLUSIVE</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
    <host>batch-slave</host>
    <port>22</port>
    <credentialsId><%= @credential_id %></credentialsId>
    <jvmOptions>-Dfile.encoding=UTF-8</jvmOptions>
  </launcher>
  <label>hello</label>
  <nodeProperties/>
</slave>
```

config/deploy.rb
```ruby
set :application, "your-awesome-app"
set :scm, :git
set :repository,  "https://github.com/your/repository.git"

set :jenkins_host, 'http://localhost:8080'
before 'deploy', 'jenkins:config_nodes'
```

config/deploy/staging.rb:
```xml
set :jenkins_template_vars, {
  :credential_id => 'STAGING-CREDENTIAL_ID'
}
```

config/deploy/production.rb:
```xml
set :jenkins_template_vars, {
  :credential_id => 'PRODUCTION-CREDENTIAL_ID'
}
```

### View Configuration

config directory structure(name your json file as a node name):
```
config
├── deploy.rb
└── jenkins
     └── views
         ├── view1.xml
         ├── view2.xml
         └── view3.xml
```

sample view configuration:
```xml
<listView>
  <name>view1</name>
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
  <includeRegex>job.*</includeRegex>
</listView>
```

deploy.rb:
```ruby
set :application, "your-awesome-app"
set :scm, :git
set :repository,  "https://github.com/your/repository.git"

set :jenkins_host, 'http://localhost:8080'
# set :jenkins_username, '' # default empty
# set :jenkins_password, '' # default empty
# set :jenkins_node_config_dir, 'config/jenkins/nodes'

before 'deploy', 'jenkins:config_views'
```

## Don't know how to write config.xml?

First, create the job, node, or view you want to manage with via the Jenkins UI.
Then, runnning following command to download them:

```
# For the job
curl -o config/jenkins/jobs/<job_name>.xml http://jenkins.example.org/job/<job_name>/config.xml

# For the node
curl -o config/jenkins/nodes/<node_name>.xml http://jenkins.example.org/computer/<node_name>/config.xml

# For the view
curl -o config/jenkins/views/<view_name>.xml http://jenkins.example.org/view/<view_name>/config.xml
```

## Known Issues

### Using mutlibyte characters in config.xml

Until [jenkins_api_client PR143](https://github.com/arangamani/jenkins_api_client/pull/143) merged,
put following code to your Gemfile:

```ruby
# FIXME after https://github.com/arangamani/jenkins_api_client/pull/143 merged
gem 'jenkins_api_client', github: 'cynipe/jenkins_api_client', branch: 'fix-multibyte-configs'
```

## TODO

  * [ ] Reverse config support. something like `cap jenkins:reverse_job`
  * [ ] CI cucumber tests on Wercker
  * [ ] Capistrano v3 support
  * [ ] Make examples triable on user's local
  * [ ] Collect usage report using Google Analytics to see who uses this tool.

## Release Notes

### 0.1.0
  * **[INCOMPATIBLE CHANGE]** Remove plugin support
  * **[INCOMPATIBLE CHANGE]** Change node configuration to use config.xml instead of json config
  * Support erb template for config.xml(need to name the file xxx.xml.erb)

### 0.0.7
  * Fix disable_job is not working with recent version of Jenkins ([#9](https://github.com/cynipe/jenkins-capistrano/pull/9))

### 0.0.6
  * Support view management ([726ad3ef](<https://github.com/cynipe/jenkins-capistrano/commit/726ad3ef817ba15a2d66503ce0dd4bc961ed92e2))
  * Support plugin management(Experimental) ([4d9964c0](https://github.com/cynipe/jenkins-capistrano/commit/4d9964c00ff95798915484ceb8b5c837b2aa03e8))

### 0.0.5.2
  * Fix cgi library loading error

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Added some feature'`)
1. Run Integration tests as following:

    $ vagrant up
    $ bundle exec cucumber

1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/e76247570c952ad3205ca7d6d3f0f7b5 "githalytics.com")](http://githalytics.com/cynipe/jenkins-capistrano)
