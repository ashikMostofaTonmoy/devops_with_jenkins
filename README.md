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

### Docker Compose

Some demo for docker compose

```sh
version: '3.1'

services:

  mongo: # container name
    image: mongo # image:tag
    restart: always
    environment: # envioronment variables
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example

  mongo-express: # container name
    image: mongo-express # image:tag
    restart: always
    ports: # port mapping
      - 8081:8081 # {host:container}
    environment: # envioronment variables
      ME_CONFIG_MONGODB_ADMINUSERNAME: root
      ME_CONFIG_MONGODB_ADMINPASSWORD: example
      ME_CONFIG_MONGODB_URL: mongodb://root:example@mongo:27017/

```

Docker-compose by default creates a seperate networt. thats why we don't need to create/declear seperate network for this type of task where we needed to create seperate network during only using `docker run`.

Run Compose file by:

```sh
docker-compose -f {filename} up -d # {filename} = mongo.yaml, -d for detach mode

docker-compose -f {filename} down # to stop container 
```

### Create Docker File

Some demo docker file and their reasons.

```sh
From node:{tag}

ENV MONGO_DB_USERNAME=admin \ #envioronment variavles 
     MONGO_DB_PWD=password 
     # Though best practice is define envioronment variables. so that we can change the value during  runtime

RUN mkdir -p /home/app 
    # RUN  command runs during container creation. 
    # CMD command runs after container creation.
    # There may be seperate `RUN` commands but only one `CMD` command
COPY . /home/app 
    # here . represents current directory '/home/app' represents directory in container
    # copy command runs on host machine , not in container 
CMD ['node','server.js']
    # this runs as entypoint command.
```

### Tagging Docker Images

To tag Image

```sh
docker build -t {custome-name}:{tag} . 
  # here . represents current folder
docker tag {currentimage}:{tag} {destination-image}:{tag}
```

### Pushing to registry

To push to the private docker registry first tag the image with `{remote-docker-domain}/{imagename}:{tag}` then use

```sh
docker login 
cat ~/my_password.txt | docker login --username foo --password-stdin
```
