set :branch, 'v1.0.0'

role :batch, 'prod-slave01.local'
# 複数ノードの場合
#role :batch, 'prod-slave02.local'
#role :batch, 'prod-slave03.local'

set :jenkins_host, 'prod-master.local'
set :jenkins_node_config_dir, 'config/jenkins/nodes/production'
