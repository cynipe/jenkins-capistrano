# ブランチはconfig/deploy.rbの設定に従う
role :batch, 'dev-slave01.local'
set :jenkins_host, 'dev-master.local'
set :jenkins_node_config_dir, 'config/jenkins/nodes/develop'

