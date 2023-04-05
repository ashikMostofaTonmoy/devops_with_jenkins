Introduction
Inside each Kubernetes cluster installation is a software-defined networking world with the sole purpose of transferring data from a source to a destination.

Depending on your CNI of choice, this data path can be customizable, bringing the flexibility required for operating a cloud-native environment.

For example, Calico has a pluggable dataplane architecture and provides multiple dataplane options that can be used to achieve an optimal outcome in any situation. These dataplanes are based on various technologies such as Linux IPTables, eBPF technology, FD.io VPP, and Windows HNS.

In this track, you will learn how to enable Calico's eBPF dataplane.


eBPF Dataplane Advantages
Calico’s eBPF dataplane is an alternative to our standard Linux dataplane (Based on iptables). While the standard dataplane focuses on compatibility by inter-working with kube-proxy and your own iptables rules, the eBPF dataplane focuses on performance, latency, and improving user experience with features that aren’t possible in the standard dataplane. As part of that, the eBPF dataplane replaces kube-proxy with an eBPF implementation. The main “user experience” feature is to preserve the source IP of traffic from outside the cluster when traffic hits a NodePort; this makes your server-side logs and network policy much more useful on that path.

The eBPF dataplane mode has several advantages over the standard Linux networking pipeline mode:

It scales to higher throughput.
It uses less CPU per GBit.
It has native support for Kubernetes services (without needing kube-proxy) that:
Reduces first packet latency for packets to services.
Preserves external client source IP addresses to the pod.
Supports DSR (Direct Server Return) for more efficient service routing.
Uses less CPU than kube-proxy to keep the dataplane in sync.

Source IP Check
Use the following command to read the customer logs.

kubectl logs -n yaobank-customer deployments/customer
Now refresh the Customer Page tab and return to the terminal.

You should see a similar result.

 * Serving Flask app "customer" (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://0.0.0.0:80/ (Press CTRL+C to quit)
10.244.82.0 - - [15/Aug/2022 06:02:11] "HEAD / HTTP/1.1" 200 -
10.244.82.0 - - [15/Aug/2022 06:02:11] "GET / HTTP/1.1" 200 -
If you look closer the IP address that created the request is logged as 10.244.82.0 which is the IP of kube-proxy pods. This is because the kube-proxy pods use NAT in oder to send external traffic to the internal resources.


Calico's eBPF Dataplane
While the default dataplane is set to IPTables because of compatibility, you are free to change this to any other dataplane if required. The best part is that this change is reversible; you can check each dataplane for your environment and determine which works best for your scenario.

Based on the eBPF technology, Calico's eBPF dataplane implements a software-defined networking solution for your Kubernetes cluster that can push the boundaries of speed and minimal resource utilization in ways that were impossible before. On top of these improvements, you will also receive features such as source IP preservation, Direct Server Return, and reduced initial packet latency.

Use the following command to instruct Calico how to communicate directly with the Kubernetes API manager.
```sh
kubectl apply -f - <<EOF
kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-services-endpoint
  namespace: tigera-operator
data:
  KUBERNETES_SERVICE_HOST: "kind-control-plane"
  KUBERNETES_SERVICE_PORT: "6443"
EOF
```
Use the following command to change the cluster dataplane to Calico's eBPF.

kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"BPF", "hostPorts":null}}}'
Use the following command to disable kube-proxy pods.

kubectl patch ds -n kube-system kube-proxy -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": "true"}}}}}'

Source IP preservation
Now that the cluster is switched to the Calico eBPF dataplane let's repeat the source IP check again.

kubectl logs -fn yaobank-customer deployments/customer
Now refresh the Customer Page tab and return to the terminal.

You should see a similar result.

 * Serving Flask app "customer" (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://0.0.0.0:80/ (Press CTRL+C to quit)
10.244.82.0 - - [15/Aug/2022 06:02:11] "HEAD / HTTP/1.1" 200 -
10.244.82.0 - - [15/Aug/2022 06:02:11] "GET / HTTP/1.1" 200 -
10.244.82.0 - - [15/Aug/2022 06:02:11] "GET / HTTP/1.1" 200 -
10.96.114.4 - - [15/Aug/2022 17:55:24] "GET / HTTP/1.1" 200 -
Note: The IP address for your environment might differ from what is shown in this section.

Perfect! this time, the correct IP address, 10.96.114.4 is written in the logs.