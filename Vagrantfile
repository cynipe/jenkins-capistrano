# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_url = 'https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box'
  config.vm.box = 'centos65-x86_64-20140116'

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '512']
  end

  config.vm.network 'forwarded_port', guest: 8080, host: 8080
  config.vm.provision :shell, :inline => (<<-SCRIPT).gsub(/^ */, '')
    curl -o /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo >/dev/null 2&>1
    rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
    yum -y install java-1.7.0-openjdk jenkins
    service jenkins start
  SCRIPT
end

