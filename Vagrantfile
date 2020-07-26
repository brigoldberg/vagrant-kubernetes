#
#  Vagrant file to create Centos/7 machine running Kubernetes
# 

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.define "poodle" do |node|
    node.vm.hostname = "poodle"
    node.vm.network "private_network", ip: "192.168.33.11", auto_config: true
    node.vm.provision :shell, :path => "bootstrap.sh"
    node.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.memory = 4096
      vb.cpus = 2
    end
  end

end
