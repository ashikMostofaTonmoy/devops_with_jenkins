# Install Docker on rockylinux/redhat

Referance lisk is: <https://docs.rockylinux.org/gemstones/docker/#add-the-docker-repository>

## Add the docker repository

Use the `dnf` utility to add the docker repository to your Rocky Linux server. Type:

```sh
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Install the needed packages

Install the latest version of Docker Engine, containerd, and Docker Compose, by running:

```sh
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Start and enable the systemd docker service (dockerd)

Use the `systemctl` utility to configure the dockerd daemon to automatically startup with the next system reboot and simultaneously start it for the current session. Type:

```sh
sudo systemctl --now enable docker
```

### Notes

```sh
docker-ce               : This package provides the underlying technology for building and running docker containers (dockerd) 
docker-ce-cli           : Provides the command line interface (CLI) client docker tool (docker)
containerd.io           : Provides the container runtime (runc)
docker-compose-plugin   : A plugin that provides the 'docker compose' subcommand 

```
