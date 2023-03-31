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

### Debug Commands

```sh
docker logs {container-id / container-name}
docekr exec -it {container-id / container-name} /bin/bash #{bash/shell location} /bin/bash or bin/sh

docker logs {container-id / container-name} | tail # give the tails of the log 
docker logs {container-id / container-name}  -f #streams the logs
```

Some helpful flags during run

```sh
docker run -d {image}:{tag} # detach mode
docker run -d -p hostport:containerport {image}:{tag} # port bindings
docker run -name {name-tag} hostport:containerport {image}:{tag} # nameing the containers
```

### Docker networks

In same docker network all the container can communicate each other only by ther name . No port / IP is required in same docker network.  

```sh
docker network ls
docker network create {network-name}
```

Example commands:  

```sh
docker run -d \ 
--name {mongo} \ # {container-name}
 --network some-network \ # {network-name}
 -e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
 -e MONGO_INITDB_ROOT_PASSWORD=secret \
 mongo:{tag}

# -e for envioronment veriables
# -d for detach mode

docker run -d \
--network some-network \ # {network-name}
 --name mongo-express \
 -p 8081:8081 \
 -e ME_CONFIG_OPTIONS_EDITORTHEME="ambiance" \
 -e ME_CONFIG_MONGODB_SERVER="web_db_1" \
 -e ME_CONFIG_BASICAUTH_USERNAME="user" \
 -e ME_CONFIG_BASICAUTH_PASSWORD="fairly long password" \
 mongo-express:{tag}
```
