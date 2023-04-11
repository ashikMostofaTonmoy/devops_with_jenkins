#!/bin/bash

# Enable ssh password authentication
echo "Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "Set root password"
echo -e "admin\nadmin" | passwd root >/dev/null 2>&1

# Install kubesphere pre-requisites
echo "Install socat & conntrack"
yum update -y -qq >/dev/null 2>&1
yum install -qq -y socat conntrack >/dev/null 2>&1
yum install -qq -y cockpit >/dev/null 2>&1
systemctl enable --now cockpit.socket 
timedatectl set-ntp 1
yum install ntp ntpdate -qq -y >/dev/null 2>&1
systemctl enable --now ntpd
ntpdate -u -s 0.centos.pool.ntp.org 1.centos.pool.ntp.org 2.centos.pool.ntp.org
systemctl restart ntpd
firewall-cmd --permanent --add-service=ntp
firewall-cmd --permanent --add-port={6443,2379,2380,10250,10251,10252}/tcp
firewall-cmd --reload
ntpq -p