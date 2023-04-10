# Usefull commands when creating microservice

Install helm and helmfile 

```sh
# helm install
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


# helmfile install
curl https://github.com/helmfile/helmfile/releases/download/v0.152.0/helmfile_0.152.0_linux_amd64.tar.gz -o helmfile_0.152.0_linux_amd64.tar.gz -fsSL
tar -zxvf helmfile_0.152.0_linux_amd64.tar.gz
sudo mv helmfile /usr/local/bin/helmfile
```

Create a different namespace

```sh
kubectl create ns microservice
kubectl apply -f config.yaml -n microservice
```

Helm check if the template is okay.

```sh
helm template -f email-service.value.yaml microservice
helm template -f values/redis-values.yaml charts/redis
```

Dry run is testing the running without running.

```sh
helm install --dry-run -f values/redis-values.yaml charts/redis
```

run using helm file

```sh
helmfile sync
```
