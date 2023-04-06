# Calico network for kubernetes

the recommended way to install Calico is through the tigera-operator.The best part about an operator-based installation is its integration with Kubernetes because it can group Pods, Deployments, Configmaps, or services that are required for your cloud-native application and give you a single interface to manage and deploy them. With the help of the operator SDK, the tigera-operator can configure, maintain or upgrade your Calico installation.

But regardless of the installation process, every CNI will have to populate its config file in /etc/cni/net.d folder and CNI binaries in /opt/cni/bin folder.

Use the following command to install the tigera-operator in your cluster.

```sh
kubectl create -f https://projectcalico.docs.tigera.io/archive/v3.24/manifests/tigera-operator.yaml
```

Use the following command to check the operator deployment.

```sh
kubectl get deployments -n tigera-operator  tigera-operator
```

Tigera-operator manifest didn't just create a simple Pod in your cluster. It extended your cluster capabilities by using Custom Resource Definitions. Use the following command to check the CRDs.

```sh
kubectl get crd
```

your cluster now offers a `tigerastatuses.operator.tigera.io` CRD, which can query the health of ProjectCalico components installed on your cluster. At this stage, the operator will constantly look for the `Installation` resource to figure out how to configure this Calico installation.

Use the following command to instruct the tigera-operator on installing Calico from the lab's pre-prepared file.

```sh
kubectl apply -f calico-configs.yaml
```

Starting with new capabilities, let's use the tigerastatus command to query the state of ProjectCalico components.

```sh
kubectl get tigerastatus
```

expected output:

```sh

NAME        AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver   True        False         False      5s
calico      True        False         False      40s
```

The tigera-operator adds a couple of other components as part of the Calico ecosystem. These components play a role in advanced features such as BGP routing, extended security policies, networking overlays such as VXLAN and IP-IP, Isto, and wireguard integration for service mesh and traffic encryption.

Calico has a pluggable data-plane architecture and multiple data planes based on IPtables, eBPF technology, and windows HNS that allows you to be in charge of your Software-defined network.

In Calico's case, these advanced features are implemented by the `calico-node` Pods that are part of a `calico-node` daemonset.

Use the following command to explore the daemonset in detail.

```sh
kubectl describe -n calico-system daemonset/calico-node
```

Let's take a closer look at the previous output. At the end of the output within the Volumes section, two directories have been shared with the host.

```sh

   cni-bin-dir:
    Type:          HostPath (bare host directory volume)
    Path:          /opt/cni/bin
    HostPathType:
   cni-net-dir:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/cni/net.d
    HostPathType:
```

These two are bidirectional mounts to put the CNI config and binaries in place.

Inside the environment section, you should see these two lines that indicate the Calico CNI `configlist` name and where it is located.

```sh
      CNI_CONF_NAME:            10-calico.conflist
      CNI_NET_DIR:              /etc/cni/net.d
```

Moving on, the content of the `10-calico.conflist` is stored in a configmap. Use the following command to examine the `cni-config` contents.

```sh
kubectl get configmap -n calico-system cni-config -o yaml
```

Use the node query command again.

```sh
kubectl get node
```

You should see a similar result, indicating that all nodes are ready.

```sh
NAME                 STATUS   ROLES                  AGE     VERSION
kind-control-plane   Ready    control-plane,master   5m37s   v1.23.6
kind-worker          Ready    <none>                 5m12s   v1.23.6
kind-worker2         Ready    <none>                 5m      v1.23.6
```
