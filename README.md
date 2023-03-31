# Commands Related to different tasks

Here will be some usefull commands for DevOps

## Docker Commands

Some basic commands:

```sh
docker run {image}:{tag}
docker pull {image}:{tag}
docker start {container-id / container-name}
docker stop {container-id / container-name}
docker ps 
docker ps -a 
docker images 

docker rm {container-id / container-name} # to remove container
docker rmi {image-name} # to remove docker image
```

Debug Commands

```sh
docker logs {container-id / container-name}
docekr exec -it {container-id / container-name} /bin/bash #{bash/shell location} /bin/bash or bin/sh
```

Some helpful flags during run

```sh
docker run -d {image}:{tag} # detach mode
docker run -d -p hostport:containerport {image}:{tag} # port bindings
docker run -name {name-tag} hostport:containerport {image}:{tag} # nameing the containers
```

Docker networks

```sh
docker network ls
docker network create {network-name}
```
