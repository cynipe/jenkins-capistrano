set :branch, 'release/1.0.1'

role :batch, 'stg-slave01.local'
role :batch, 'stg-slave02.local'
role :batch, 'stg-slave03.local'

set :jenkins_host, 'stg-master.local'
set :jenkins_node_config_dir, 'config/jenkins/nodes/staging'
set :jenkins_template_vars, {
  slave01: {
    credential_id: 'STAGING-SLAVE01-CREDENTIAL',
  },
  slave02: {
    credential_id: 'STAGING-SLAVE02-CREDENTIAL',
  },
  slave03: {
    credential_id: 'STAGING-SLAVE03-CREDENTIAL',
  }
}
