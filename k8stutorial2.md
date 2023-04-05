A Kubernetes cluster offers a suitable environment to run multiple workloads that can efficiently use your hardware or cloud resources. But this increase also expands the attack surface in your environment and makes you susceptible to more ways to compromise your environment.

You can take multiple steps to battle this and limit the attack surface. Zero-trust security posture, network policy, and observability are some of the procedures you can implement.

In this section, you will learn about the Zero-trust security posture and Kubernetes Network Policy resource.


Zero Trust Security posture
Before starting to write policies, let's talk about security.

Zero trust is an effective and popular security posture. While establishing Zero trust goes beyond network policy, it is worth noting that its principles could benefit any environment.

Usually, we assume that threats are external, so we strengthen our security protocols accordingly. However, in a zero-trust environment, we view our network's external and internal areas with the same threat level. This change of perspective dictates viewing internal resources as compromised from the beginning.

That is why the zero-trust posture implements isolation as a form of containing a compromise for when it happens.


Kubernetes Network Policy
Kubernetes has a built-in resource that can shape the security posture of your cloud-native environment and workloads. However, like networking, Kubernetes doesn't enforce these policies and delegates the responsibility to the CNI plugins, so it is vital to use a CNI that offers such capability if you are interested in security. The network plugin implements network policies. To use network policies, you must use a networking solution that supports NetworkPolicy. Creating a NetworkPolicy resource without a controller implementing it will have no effect.

KNP is a unique resource that can restrict networking communication for resources in Kubernetes.

KNP YAML file starts with the following header.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
Like any Kubernetes resources, you can define a name and a namespace for your policies in the metadata section of the YAML file.

Note: It is important to note that KNP resources apply to namespaces, which means you have to create a policy in each namespace to secure a cluster with multiple namespaces.

metadata:
  name: test-network-policy
  namespace: default
Specification podSelector, policyTypes, ingress and egress.


Workload Deployment
Let's deploy a workload on the cluster to better understand the KNP resource and its implications. A workload is one or multiple Pods, services, and other resources that work together to provide functionality to our users. For this lab, we will deploy the YaoBank workload that consists of three separate tiers.

Application Diagram

Use the following command to install the Yaobank demo application.

kubectl apply -f yaobank.yaml
The YaoBank application manifest adds a couple of deployments and services to your cluster. Use the following commands to make sure all deployments are successfully rolled out.

kubectl rollout status -n yaobank-customer deployments/customer
kubectl rollout status -n yaobank-summary deployments/summary
kubectl rollout status -n yaobank-database deployments/database
Now that the YaoBank application is fully deployed, it is time to visit the application web page. Use the Customer Page tab to view the simple YaoBank web page.Application Diagram


Connectivity Test
It is worth noting that in the absence of policies, the default behavior of Kubernetes is to permit all traffic. However, this behavior changes to block all traffic except those explicitly allowed by policies when a policy is present.

For example, currently, customer Pods can directly communicate with the database, which is a huge security concern. In any scenario, you should ensure that network traffic is always isolated and that the traffic flows intended for the destination.

Use the following command to check the connectivity.

kubectl exec -it -n yaobank-customer deployments/customer -- curl --connect-timeout 5 http://database.yaobank-database:2379/v2/keys?recursive=true

KNP Default Deny
Policies can offer isolation, but the critical fact about policies is that these resources should be tailored to your needs.

Use the following command to isolate the yaobank-database namespace.

kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
 name: default-deny
 namespace: yaobank-database
spec:
 podSelector: {}
 policyTypes:
 - Ingress
 - Egress
EOF
Note: It is possible to omit the namespace section from your policies. However, since a KNP resource is bound to a namespace, it will automatically get the default namespace value.


Permit The Expected Traffic
Now that you have established isolation in the yaobank-database namespace, you must write a permit policy to allow expected traffic to flow in and out of your namespace.

Use the following command to add a permit policy.

kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: p-summary2database
  namespace: yaobank-database
spec:
  podSelector:
    matchLabels:
      app: database
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            ns: summary
      - podSelector:
          matchLabels:
            app: summary
  egress:
    - to:
      - namespaceSelector:
          matchLabels:
            ns: summary
      - podSelector:
          matchLabels:
            app: summary
EOF

Policy Behavior
Previously we talked about the absence of policy and how Kubernetes acts in the absence of it. Let's remove the default deny policy and verify the claim.

Use the following command to remove the default-deny that you implemented in the yaobank-database namespace.

kubectl delete networkpolicy default-deny -n yaobank-database
Use the following command to check the connectivity.

kubectl exec -it -n yaobank-customer deployments/customer -- curl --connect-timeout 5 http://database.yaobank-database:2379/v2/keys?recursive=true

Conclusion
Kubernetes policy is excellent for targeting namespaced traffic. However, a cluster has many parts that these policies can not control. For example, you can not target a node by its node name. Because these policies are bound to namespaces, you must apply a default deny to every namespace within your cluster if you wish to establish true isolation.