# /usr/bin/env bash

sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
systemctl disable firewalld
systemctl stop firewalld

yum -y install epel-release
yum -y install tmux tree vim nginx

swapoff -a
sed -i '/swap/d' /etc/fstab

#######################################################
## Configure Host OS
#######################################################
sed -i '/swap/d' /etc/fstab
swapoff -a

modprobe br_netfilter

cat <<EOF > /etc/sysctl.d/51-kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system


#######################################################
## Install Docker and start services
#######################################################
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y --setopt=obsoletes=0 docker-ce-18.06.1.ce-3.el7
systemctl enable docker; systemctl start docker

cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

systemctl daemon-reload
systemctl restart docker

#######################################################
## Install Kubernetes and start services
#######################################################
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

yum clean all
yum install -y kubelet-1.18.1-0 kubeadm-1.18.1-0 --disableexcludes=kubernetes
systemctl enable kubelet; systemctl start kubelet
kubeadm init --pod-network-cidr=10.244.0.0/16 

