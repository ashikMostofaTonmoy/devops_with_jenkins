
# DEMO STEPS

Step 1: Pre-requisites

1.a.. Check the OS, Hardware Configurations & Network connectivity
1.b.. Turn off the swap & firewall
```sh
sudo swapoff -a
sudo systemctl stop firewalld 
sudo systemctl disable firewalld 
```

Step 2. Configure the local IP tables to see the Bridged Traffic

2.a.. Enable the bridged traffic
```sh
lsmod | grep br_netfilter
sudo modprobe br_netfilter
```

2.b.. Copy the below contents in this file.. `/etc/modules-load.d/k8s.conf`

Content:
```sh
br_netfilter
```
2.c.. Copy the below contents in this file.. `/etc/sysctl.d/k8s.conf`

Content:
```sh
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

```sh
sudo sysctl --system
```
Step 3. Install Docker as a Container RUNTIME

3.a.. Uninstall any Older versions
```sh
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
```

3.b.. Install Yum Utilities | Config Manager
```sh
sudo yum install -y yum-utils
```

3.c.. Setup the Docker Repository
```sh
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

3.d.. Install Docker Engine, Docker CLI, Docker RUNTIME
```sh
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
Step 4. Configure Docker Daemon for cgroups management & Start Docker

4.a.. Create directory 
```sh
$ sudo mkdir -p /etc/docker
```
4.b.. Copy the below contents in this file.. `/etc/docker/daemon.json`

```sh
sudo vi /etc/docker/daemon.json
```

Content:
```sh
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
```

```sh
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
sudo systemctl status docker
```
Step 5. Install kubeadm, kubectl, kubelet

5.a.. Copy the below contents in this file.. `/etc/yum.repos.d/kubernetes.repo`

Content:
```sh
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum...\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum... https://packages.cloud.google.com/yum...
exclude=kubelet kubeadm kubectl
```
or 

```sh

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
```

5.b.. Set SELinux in permissive mode (effectively disabling it)
```sh
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo dnf install -y {kubelet,kubeadm,kubectl} --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
```

Step 6. Configuring a cgroup driver

Ignore if docker is used as a CRI

Step 7. Deploy a  kubernetes cluster using kubeadm

**Run only in Master node**

```sh
kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=master_nodeIP
```

To start using your cluster, you need to run the following as a regular user:

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Alternatively, if you are the root user, you can run:
```sh
export KUBECONFIG=/etc/kubernetes/admin.conf
```
You should now deploy a pod network to the cluster.

Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/c...

Then you can join any number of worker nodes by running the following on each as root:
```sh
kubeadm join 192.168.74.10:6443 --token l431j0.0tz0bbuu7hj64lw5 \
        --discovery-token-ca-cert-hash sha256:1743115f18a7b8761105ff5465cd1aeed74a2e8a3f326405da61681d07fdb0e0
```
Step 8. Install CNI for POD Networking

# Run only in Master node

calico Networks:

```sh
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
```
Step 9. Join the worker nodes to the master

# Run in Worker Nodes as "Root"
```sh
kubeadm join 192.168.74.10:6443 --token l431j0.0tz0bbuu7hj64lw5 \
        --discovery-token-ca-cert-hash sha256:1743115f18a7b8761105ff5465cd1aeed74a2e8a3f326405da61681d07fdb0e0
```
# Make sure to replace your tokens and IP's in the above command accordingly