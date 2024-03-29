# Kubernetes (K8S)

* to check everything locally , install `minikube` , a choosen hypervisor according to the os you are on
* install `kubectl` if not installed by default
* you may need to restart/logout the pc to take the change effect
  
  >In this case we are using `kvm2` hypervisor

```sh
minikube start --driver=kvm2
```

```sh
kubectl get nodes # this gets status of the nodes
minikube status 
```

> `kubectl cli` for configuring minikube cluster
> `minikube cli` for up/deletiog cluster

## Create kubernetes cluster on Redhat based system

See Reference:

1. <https://www.linuxtechi.com/how-to-install-kubernetes-cluster-rhel/>
2. <https://www.golinuxcloud.com/deploy-multi-node-k8s-cluster-rocky-linux-8/>
3. <https://www.centlinux.com/2022/11/install-kubernetes-master-node-rocky-linux.html>
4. <https://wiki.gentoo.org/wiki/SELinux/Tutorials/Permissive_versus_enforcing#:~:text=The%20use%20of%20the%20setenforce%20command%20is%20useful>,to%20enable%20enforcing%20mode.%20The%20selinux%20configuration%20file
5. <https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/>
6. <https://docs.rockylinux.org/guides/network/basic_network_configuration/>
7. <https://www.golinuxcloud.com/set-static-ip-rocky-linux-examples/>
8. <https://www.centlinux.com/2022/11/install-kubernetes-master-node-rocky-linux.html>
9. <https://github.com/kubernetes/kubernetes/issues/115824>

**Step 1: Disable swap space**
For best performance, Kubernetes requires that swap is disabled on the host system. This is because memory swapping can significantly lead to instability and performance degradation.

To disable swap space, run the command:

```sh
sudo swapoff -a
```

To make the changes persistent, edit the `/etc/fstab` file and remove or comment out the line with the swap entry and save the changes

```sh
sudo vi /etc/fstab
```

after commentsthis should look like this

```sh
#/dev/mapper/rl-swap     none                    swap    defaults        0 0
```

**Step 2: Disable SELinux**
Additionally, we need to disable SELinux and set it to ‘permissive’ in order to allow smooth communication between the nodes and the pods.

To achieve this, open the SELinux configuration file.

```sh
sudo setenforce 0
sudo vi /etc/selinux/config
```

Change the SELINUX value from enforcing to permissive.

```sh
SELINUX=permissive
```

Alternatively, you use the sed command as follows.

```sh
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

**Step 3 Configure networking in master and worker node**
Some additional network configuration is required for your master and worker nodes to communicate effectively. On each node, edit the  `/etc/hosts` file.

```sh
sudo vi /etc/hosts
```

Next, update the entries as shown

```sh
10.128.15.228 master-node-k8          // For the Master node
10.128.15.230 worker-node-1-k8       //  For the Worker node
```

Alternativly we can do it like this:

```sh
sudo hostnamectl set-hostname master # for master node
sudo hostnamectl set-hostname worker-1 # for worker node

sudo tee /etc/hosts <<EOF
192.168.30.95 master
192.168.30.96 worker01
192.168.30.97 worker02
EOF

# or like this
sudo cat <<EOF>> /etc/hosts
192.168.100.234 master
192.168.100.235 worker01
192.168.100.236 worker02
EOF

# or like this
sudo echo 192.168.116.131 kubemaster-01.centlinux.com kubemaster-01 >> /etc/hosts

```

Save and exit the configuration file. Next, install the traffic control utility package:

```sh
sudo dnf install -y iproute-tc
```

**Update system**
Update all the nodes you intend to use in the cluster, to have the latest packages and latest kernel patches. Linux Kernel packages may be updated by the above command. You are advised to reboot your nodes for some changes to take effect. Therefore, reboot your Linux server before moving forward.

```sh
sudo dnf -y update && sudo systemctl reboot
```

**Step 4: Allow firewall rules for k8s**
For seamless communication between the Master and worker node, you need to configure the firewall and allow some pertinent ports and services as outlined below.

Kubernetes uses following service ports at Master node.

Port | Protocol | Purpose
---|---|---
6443|TCP | Kubernetes API server
2379-2380 | TCP |etcd server client API
10250| TCP | Kubelet API
10251| TCP |kube-scheduler
10252| TCP | kube-controller-manager

Therefore, you need to allow these service ports in Linux firewall.

On Master node, allow following ports,

```sh
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --reload
```

On Worker node, allow following ports,

```sh
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=30000-32767/tcp                                                 
sudo firewall-cmd --reload
```

```sh
sudo firewall-cmd --permanent --add-port={6443,2379,2380,10250,10251,10252}/tcp
sudo firewall-cmd --reload

```

**Step 5:  Install `Containerd` container runtime**

To achieve this, we need to configure the prerequisites as follows:

First, create a modules configuration file for Kubernetes.

**Configure persistent modules**
Kubernetes requires "overlay" and "br_netfilter" Kernel modules. Therefore, you can use following group of commands to permanently enable them.

```sh
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
```

Alternatively,

```sh
sudo vi /etc/modules-load.d/k8s.conf
```

Add these lines and save the changes

```sh
overlay
br_netfilter
```

**Then load both modules using the modprobe command.**

```sh
sudo modprobe overlay
sudo modprobe br_netfilter
```

**configure the required sysctl parameters as follows**
First, create a modules configuration file for Kubernetes.

```sh
sudo vi /etc/sysctl.d/k8s.conf
```

Add the following lines:

```sh
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
```

Or , it can be done by this

```sh
sudo tee /etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

```sh
# not recommended
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

**Reload sysctl**
Reload Kernel parameter configuration files with above changes.

```sh
sudo sysctl --system
```

**Install dependencies**
Don't know why /where we need this

```sh
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

**See the `docker-installetion-rockylinux.md` file to install docker.**

```sh
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

After a successful installation, create a configuration directory for cotainerd

```sh
sudo mkdir -p /etc/containerd 
# sudo containerd config default > /etc/containerd/config.toml
```

After installation, backup the original containerd configuration file and generate a new file as follows.

```sh
sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.originalbackup
sudo containerd config default > /etc/containerd/config.toml
```

Edit Containerd configuration file by using vim text editor.

```sh
sudo vi /etc/containerd/config.toml
```

If this doesn't allow, Use `sudo su` to go to root. Then run the command.

Locate and set SystemdCgroup parameter in this file, to enable the systemd cgroup driver for Containerd runtime.

```sh
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

Enable and start Containerd service.

```sh
sudo systemctl enable --now containerd.service
```

**Step 6: Install Kubernetes Packages and Initialize the Control Plane**
To initialize the control plane, log in to the master node.

Check and verify that the `br_netfilter` module is loaded to the kernel:

```sh
lsmod | grep br_netfilter
```

With everything required for Kubernetes to work installed, let us go ahead and install Kubernetes packages like kubelet, kubeadm and kubectl. Create a Kubernetes repository file.

Use this one. if failsthen `edit` to the next file.

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

sudo dnf install -y {kubelet,kubeadm,kubectl} --disableexcludes=kubernetes
```

Better if use `sudo vi /etc/yum.repos.d/kubernetes.repo`

```sh
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo dnf install -y {kubelet,kubeadm,kubectl} --disableexcludes=kubernetes
```

```sh
kubectl version --output=json
# or
kubectl version --output=yaml
```

**Setup Worker Node**
For Worker node all the steps before is same except `Step 6`. you only need to get the token from master node and add the token to worker node. Following command on master node will generate the command to connect worker node.

```sh
kubeadm token create --print-join-command
```

**Initialize Kubeadm On Master Node To Setup Control Plane**
Bootstrap the cluster by running the kubeadm init command with the following flags:

* --control-plane-endpoint : set the shared endpoint for all control-plane nodes such as  DNS/IP
* --pod-network-cidr : Used to set a Pod network add-on CIDR
* --cri-socket : Use this if you have more than one container runtime to set runtime socket path. In our case, we have installed only containerd runtime.
* --apiserver-advertise-address : Set advertise address for this particular control-plane node's API server

Here you need to consider two options.

Master Node with Private IP: If you have nodes with only private IP addresses and the API server would be accessed over the private IP of the master node.
Master Node With Public IP: If you are setting up a Kubeadm cluster on Cloud platforms and you need master Api server access over the Public IP of the master node server.
Only the Kubeadm initialization command differs for Public and Private IPs.

Execute the commands in this section only on the master node.

If you are using Private IP for master Node,

Set the following environment variables. Replace 10.0.0.10 with the IP of your master node.

```sh
IPADDR="192.168.30.99"
NODENAME=$(hostname -s)
POD_CIDR="10.0.0.0/16"
```

If you want to use the Public IP of the master node,

Set the following environment variables. The IPADDR variable will be automatically set to the server’s public IP using `ifconfig.me` curl call. You can also replace it with a public IP address

```sh
IPADDR=$(curl ifconfig.me && echo "")
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"
```

Now, initialize the master node control plane configurations using the kubeadm command.

For a Private IP address-based setup use the following init command.

```sh
sudo kubeadm init --apiserver-advertise-address=$IPADDR --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR --node-name $NODENAME --ignore-preflight-errors Swap
```

`--ignore-preflight-errors Swap` is actually not required as we disabled the swap initially.
`--apiserver-cert-extra-sans` is a command-line argument for kubeadm init command in Kubernetes that specifies additional Subject Alternative Names (SANs) for the Kubernetes API server certificate. SANs are used to specify additional hostnames or IP addresses that can be used to connect to the Kubernetes API server.

For example, if you have a Kubernetes cluster running on a domain name `example.com`, but you want to access it using an IP address as well, you can use this flag to add the IP address as an additional SAN entry in the API server certificate.

For public IP address-based setup use the following init command.

Here instead of --apiserver-advertise-address we use --control-plane-endpoint parameter for the API server endpoint.

```sh
sudo kubeadm init \
  --control-plane-endpoint=$IPADDR  \
  --apiserver-cert-extra-sans=$IPADDR \
  --pod-network-cidr=$POD_CIDR \
  --node-name $NODENAME \
  --ignore-preflight-errors Swap
```

All the other steps are the same as configuring the master node with private IP.

Alternatively, run the command below to initialize your cluster. Replace master with the hostname of your master node.

```sh
sudo kubeadm init \
  --pod-network-cidr=10.10.0.0/16 \
  --control-plane-endpoint=master
```

> Note: You can also pass the kubeadm configs as a file when initializing the cluster. See [Kubeadm Init with config file](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file "Kubeadm Init with config file")

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

```sh
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/
```

On a successful kubeadm initialization, you should get an output with kubeconfig file location and the join command with the token as shown below. Copy that and save it to the file. we will need it for joining the worker node to the master.

You can now join any number of `control-plane nodes` by copying certificate authorities
and service account keys on each node and then running the following as root:

```sh
  kubeadm join 192.168.1.104:6443 --token lw4xrh.kgw5ty1spl9cduvl \
        --discovery-token-ca-cert-hash sha256:fa04cc2bd08f85ab0a17bbb813aba144eb1700af1e6ae2f7a07db245ff41e6a1 \
        --control-plane 
```

Then you can join any number of `worker nodes` by running the following on each as root:

```sh
kubeadm join 192.168.1.104:6443 --token lw4xrh.kgw5ty1spl9cduvl \
        --discovery-token-ca-cert-hash sha256:fa04cc2bd08f85ab0a17bbb813aba144eb1700af1e6ae2f7a07db245ff41e6a1 
```

Now, verify the kubeconfig by executing the following kubectl command to list all the pods in the kube-system namespace.

```sh
kubectl get po -n kube-system
```

**Step 7: Setup cluster network**

1. First, install the operator on your cluster.

  ```sh
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
  ```

2. Download the custom resources necessary to configure Calico

  ```sh
  curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml -O
  ```

>If you wish to customize the Calico install Like the `CIDR` blocks, customize the downloaded custom-resources.yaml manifest locally.

3. Create the manifest in order to install Calico.

  ```sh
  kubectl create -f custom-resources.yaml
  ```

4. [Install `calicoctl`](https://docs.tigera.io/calico/latest/operations/calicoctl/install) command line tool to manage Calico resources and perform administrative functions.

In the host, open a terminal prompt, and navigate to the location where you want to install the binary.
TIP
Consider navigating to a location that's in your `PATH`. For example, `/usr/local/bin/`.

Use the following command to download the calicoctl binary.

```sh
curl -L https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64 -o calicoctl
```

Set the file to be executable.

```sh
chmod +x ./calicoctl
sudo mv calicoctl /usr/local/bin/
```

```sh
kubectl annotate node my-node projectcalico.org/RouteReflectorClusterID=244.0.0.1
```
<!-- 
**The next step is to install Calico CNI (Container Network Interface).**
It is an opensource project used to provide container networking and security. After Installing Calico CNI, nodes state will change to Ready state, DNS service inside the cluster would be functional and containers can start communicating with each other.

Calico provides scalability, high performance, and interoperability with existing Kubernetes workloads. It can be deployed on-premises and on popular cloud technologies such as Google Cloud, AWS and Azure.

To install Calico CNI, run the following command from the master node

```sh
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml
# calico version always changes. make sure its latest version
```

To confirm if the pods have started, run the command:

**Configure a node to act as a route reflector**
Calico nodes can be configured to act as route reflectors. To do this, each node that you want to act as a route reflector must have a cluster ID - typically an unused IPv4 address.

To configure a node to be a route reflector with cluster ID 244.0.0.1, run the following command.

```sh
kubectl annotate node my-node projectcalico.org/RouteReflectorClusterID=244.0.0.1
```

Typically, you will want to label this node to indicate that it is a route reflector, allowing it to be easily selected by a BGPPeer resource. You can do this with kubectl. For example:

```sh
kubectl label node my-node route-reflector=true
```

[Configuring Route Reflectors in Calico](https://www.tigera.io/blog/configuring-route-reflectors-in-calico/)

```sh
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calicoctl.yaml
```

**Installing `calicoctl`**
You can then run commands using kubectl as shown below.

```sh
kubectl exec -ti -n kube-system calicoctl -- /calicoctl get profiles -o wide
```

We recommend setting an alias as follows.

```sh
alias calicoctl="kubectl exec -i -n kube-system calicoctl -- /calicoctl"
```

```sh
kubectl annotate node master projectcalico.org/RouteReflectorClusterID=244.0.0.1
``` -->

## Some basic commands for K8S

Use the following command to determine your node `STATUS.`

```sh
kubectl get node
```

Use the following command to get more details about the control-plane node status.

```sh
kubectl describe node kind-control-plane
```

```sh
kubectl get pod
kubectl get services
kubectl create # ... to to create something
kubectl create deployment nginx-demo --image=nginx # to create deployment
kubectl get deployment 
kubectl get replicaset
kubectl get service
kubectl edit deployment <name-of-deployment>
kubectl describe pod <pod-name>
kubectl logs <pod-name> # for debugging
kubectl exec -it <pod name> -- / bin/bash # to get into the container
kubectl delete deployment <deployment-name> # to delete deployment 
kubectl delete pods -n <namespace> <pod-name> --grace-period=0 --force

# but mainly we use to apply all this 
kubectl apply -f <filename.yaml> #to up  the deployment from file
kubectl delete -f <filename.yaml> #to delete the deployment from file
```

* To keep secret text / db credential / other password in config file 1st change the text in `base64` formate from terminal. Then put the text in the config file. so that other people gets confused :D.

```sh
echo -n 'ashik' | base64
```

The secretss should be up before dploying other things. otherwise they won't find where to reference.

`---` this shows that `yaml` file is seperated . it's possible to put two dirrerent file in a monolith file. but they are treated as different files

* Default `Namespace` should be kept clean.
* It's better to group different services and tasks in a seperate namespace.
* a `Namespace` can be used by multiple namespaces.
* Each `Namespace` has their own configmap, secrets.

To create namespace:

```sh
kubectl create namespace my-ns
```

> By default everything is installed or configured in `default`namespace.

To change default namespace you may need `kubectx`. To install kubectx

```sh
sudo add-apt-repository 'deb [trusted=yes] http://ftp.de.debian.org/debian buster main' # adding repository
sudo apt update
sudo apt install kubectx
```

If public key is missinng when `sudo apt update`, add public key by

```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DCC9EFBF77E11517 \
# change `DCC9EFBF77E11517` value according to terminal.
```

use `kubens` to list all available namespace

```sh
kubens
kubectl get ns # or you can check by this
kubens <custome-namespace>
````

This will change default name space to custome namespace. If you need to check resource from other namespace  use commands like this:

```sh
kubectl get pod -n <default/name-space>
kubectl get pods --all-namespaces # for all namespaces
```

### Deploying the Dashboard UI

<https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/>
The Dashboard UI is not deployed by default. To deploy it, run the following command:

```sh
kubectl apply -f https://raw.githubusercont ent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

You can enable access to the Dashboard using the `kubectl` command-line tool, by running the following command:

```sh
kubectl proxy
```

if there are no previous user created

### setup `Ingress`

install ingress controller in miniKube

```sh
minikube addons enable ingress
```

this automatically implements k8s `nginx` implementation of ingress controller. To check if it's running

```sh
kubectl get pod -n kube-system # or in
kubectl get pod -n ingress-nginx
```

### Adding helm repo

```sh
helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Install prometheus stack for monitoring

```sh
helm install prom-operator-01 prometheus-community/kube-prometheus-stack
```

To check everything is installed

```sh
kubectl get all -n <namespace-name>
kubectl get configmap
```

### Get docker login cred

The Structure of Secret Object
The Kubernetes Secret object has a special type of kind for private registries as;

```sh
type: kubernetes.io/dockercfg
type: kubernetes.io/dockerconfigjson
```

Let’s remember the structure of Secret object:

```sh
apiVersion: v1
kind: Secret
metadata:
  name: secret-registry
type: kubernetes.io/dockercfg
data:
  .dockercfg: |
    "<base64 encoded ~/.docker/config.json-file>"
```

or

```sh
apiVersion: v1
kind: Secret
metadata:
  name: secret-registry
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: |
    "<base64 encoded ~/.docker/config.json-file>"
```

**Create Secret Object from login Command**
When we login into the container registry, the credentials are saved in the `~/.docker/config.json` file. We can get the required information from this file and can place it inside the `Secret` file `data` portion.

For AWS ECR;

```sh
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-id>.dkr.ecr.us-east-1.amazonaws.com
```

For hosted private container registry;

```sh
docker login -u username -p password  https://private-registry
```

Firstly, after logging in to the container registry, create secret data from the stored data as follows;

```sh
cat ~/.docker/config.json | base64
```

You can now copy the output as secret data and place it in the file's data portion. Next, give it a try in the K8s cluster.

**Create Secret Object with kubectl Command**
It is also possible to create the Secret object with the help of kubectl command. They are listed as follows.

Secondly, you can also create the `Secret` object from `~/.docker/config.json` directly as follows;

Go to home directory. then run the following.

```sh
kubectl create secret generic registrypullsecret \
  --from-file=.dockerconfigjson=.docker/config.json \
  --type=kubernetes.io/dockerconfigjson
```

When creating applications, you may have a Docker registry that requires authentication. In order for the nodes to pull images on your behalf, they have to have the credentials. You can provide this information by creating a dockercfg secret and attaching it to your service account.

```sh
kubectl create secret docker-registry NAME --docker-username=user --docker-password=password --docker-email=email [--docker-server=string] [--from-literal=key1=value1] [--dry-run]
```

Examples
If you don't already have a .dockercfg file, you can create a dockercfg secret directly by using:

```sh
kubectl create secret docker-registry my-secret --docker-server=DOCKER_REGISTRY_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL
```

#### Tresting Services directly to localmachine

```sh
kubectl port-forward service/<service-name> <local-machine-port>:<Service-port> -n <namespace>

# example
kubectl port-forward service/api-gateway-service 8888:80 -n mynamespace
kubectl port-forward --address 0.0.0.0 service/traefik 8000:8000 8080:8080 443:4443 -n testns 
```

If want to run in background mode

```sh
kubectl port-forward service/<service-name> <local-machine-port>:<Service-port> -n <namespace> &
# added '&' at the end to run anything in background
# example
kubectl port-forward service/api-gateway-service 8888:80 -n mynamespace &
```

> All of the codes are in here
> <https://gitlab.com/ashikMostofaTonmoy/youtube-tutorial-series-from-nana>
> Microservice - 149
