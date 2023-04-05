https://play.instruqt.com/tigera/invite/cgzdhiwnjrsy?utm_source=instruqt&utm_medium=share_button&utm_campaign=referral

In the previous track, we briefly mentioned Kubernetes Network Policy limitations. I assume you are eager to know more about this topic and what could be done to break these limitations.

Some Kubernetes CNI projects extend the Kubernetes Security features by adding their security resources to the mix.

For example, on top of a policy engine, Calico also offers multiple specialized security resources that provide an elegant way to lock down your cluster and only allow the expected traffic to flow. As a result, you can integrate these security resources with projects such as Istio or use them to skip the vendor lockdown by using the same syntax in any environment.


**Calico Global Security Policy Resource**
Calico provides a GlobalNetworkPolicy resource that can affect your cluster as a whole. This resource type can affect namespace (traffic inside a cluster) and non-namespace (external and NIC) traffic and greatly extend the security capabilities that your cluster can offer.

Note: In this policy, traffic from non-namespaced and kube-system, calico-system, calico-apiserver namespaces are excluded deliberately to simplify the flow of content.

Use the following command to establish isolation.
```sh
kubectl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: default-app-policy
spec:
  namespaceSelector: has(projectcalico.org/name) && projectcalico.org/name not in {"kube-system", "calico-system", "calico-apiserver"}
  types:
  - Ingress
  - Egress
  egress:
    - action: Allow
      protocol: UDP
      destination:
        selector: k8s-app == "kube-dns"
        ports:
          - 53
EOF
```
A Calico Global Security Policy also affects the resources that you will create in the future. Any namespace you will create in the future will be affected by the security posture you have implemented with your global policies.


Calico Network Policy Resource
Similar to a Kubernetes security policy, Calico offers a Network Security Policy resource that can affect namespace traffic. However, Calico Network Security Resource provides an expanded range of sectors and a feature-rich KNP-like syntax that can help you block or permit traffic that might be difficult or impossible to restrict with KNP resources.

kubectl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: p-external2customer
  namespace: yaobank-customer
spec:
  selector: app == "customer"
  ingress:
  - action: Allow
    protocol: TCP
    destination:
      selector: app == "customer"
  egress:
  - action: Allow
    protocol: TCP
    destination:
      serviceAccounts:
        names:
          - summary
      namespaceSelector: ns == "summary"
---
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: p-customer2summary
  namespace: yaobank-summary
spec:
  selector: app == "summary"
  ingress:
  - action: Allow
    protocol: TCP
    destination:
      selector: app == "summary"
      ports:
      - 80
  egress:
  - action: Allow
    protocol: TCP
    destination:
      selector: app == "database"
      namespaceSelector: projectcalico.org/name == "yaobank-database"
EOF

Interoperability
If you recall, previously, we implemented some Kubernetes Network Policy Resources. These resources are still used within our database namespace to permit the network traffic.

Use the following command to view the Calico Global Security policy.

kubectl get gnp
Use the following command to view the Calico Security Policy resources.

kubectl get cnp -A
Use the following command to view the Kubernetes Network Policy resources.

kubectl get networkpolicy

Conclusion
In this track, we have implemented some unique Calico resources to secure our Lab cluster even further than possible. While this is just a taste of what Calico can offer, it should be a great testament to the flexibility of Kubernetes and the power of its CNIs.

Exit
