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
2. https://www.golinuxcloud.com/deploy-multi-node-k8s-cluster-rocky-linux-8/
3. https://www.centlinux.com/2022/11/install-kubernetes-master-node-rocky-linux.html
4. https://wiki.gentoo.org/wiki/SELinux/Tutorials/Permissive_versus_enforcing#:~:text=The%20use%20of%20the%20setenforce%20command%20is%20useful,to%20enable%20enforcing%20mode.%20The%20selinux%20configuration%20file
5. https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
6. https://docs.rockylinux.org/guides/network/basic_network_configuration/
7. https://www.golinuxcloud.com/set-static-ip-rocky-linux-examples/

**Step 1: Disable swap space**
For best performance, Kubernetes requires that swap is disabled on the host system. This is because memory swapping can significantly lead to instability and performance degradation.

To disable swap space, run the command:

```sh
sudo swapoff -a
```

**Step 2: Disable SELinux**
Additionally, we need to disable SELinux and set it to ‘permissive’ in order to allow smooth communication between the nodes and the pods.

To achieve this, open the SELinux configuration file.

```sh
sudo vi /etc/selinux/config
```

Change the SELINUX value from enforcing to permissive.

```sh
SELINUX=permissive
```

Alternatively, you use the sed command as follows.

```sh
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

Save and exit the configuration file. Next, install the traffic control utility package:

```sh
sudo dnf install -y iproute-tc
```

**Step 4: Allow firewall rules for k8s**
For seamless communication between the Master and worker node, you need to configure the firewall and allow some pertinent ports and services as outlined below.

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

**Step 5:  Install `Containerd`**
See the `docker-installetion-rockylinux.md` file to not install docker but You'll need the repo to install containerd.

```sh
sudo dnf -y install containerd.io
```


```sh
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl
```

```sh
kubectl version --output=json
# or
kubectl version --output=yaml
```

## Some basic commands for K8S

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

> All of the codes are in here
> <https://gitlab.com/ashikMostofaTonmoy/youtube-tutorial-series-from-nana>
> Microservice - 149
