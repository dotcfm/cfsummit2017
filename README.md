# Code samples from "Dockerizing a ColdFusion Enterprise Application, a Case Study"

ColdFusion Summit 2017, November 16, 2017 1:45 PM - 2:45 PM

>These demos were performed on Windows 10 with Docker Version 17.09.0-ce-win33

**BINARIES NOT INCLUDED**

These files are referenced by the demo code and required for building Docker images but are not included in this distribution:

- ColdFusion_2016_WWEJ_linux64.bin (adobe.com)
- hotfix-004-302561.jar (adobe.com)
- mysql-connector-java-5.1.42-bin (mysql.com)


# Demo 1: Minimal Example

A **minimal** example of building a CF Docker image.

- build the image
- run the container

REQUIREMENTS

- The build requires the Linux x64 ColdFusion installer `ColdFusion_2016_WWEJ_linux64.bin` file to be in the `demo1` folder.

TO BUILD

    cd cfdemo1
    docker build -t cfdemo1 .

FILES OF INTEREST

    Dockerfile
    myapp\index.cfm

TO RUN

    docker run -ti --rm -p 8500:8500 cfdemo1

Test by browsing to http://localhost:8500


## Demo 1: Developer Use Case

Files on the host can be bind mounted to the container using `-v c:\host\path:/container/path`.

RUN DEVELOPER USE CASE

    docker run -ti --rm -p 8500:8500 -v %cd%\myapp:/opt/coldfusion2016/cfusion/wwwroot/myapp cfdemo1

Test by browsing to http://localhost:8500/myapp and modifying files in  `myapp\`.


# Base Image (Required for Demo 2)

A base image used by some of the examples.

TO BUILD

    cd cfbaseos
    docker build -t cfbaseos .


# Demo 2: Real-World Example

A **real-world** example of building a CF Docker image including (everything but the kitchen sink):

- uses a local base image `cfbaseos` to eliminate 3rd party build-time dependencies
- uses multi-stage builds feature and `--squash` to reduce the image size
- automates CF hotfix 4 installation
- automates keytool for certificate installation
- relocate the CF web root to `/var/www` in `server.xml`
- bind mount the project’s source code `www\` to `/var/www`
- bind mount the CF configuration files `cf\` to their respective locations in the CF directory
- add an NGINX service to the stack which will function as a reverse proxy and a static cache
- use `docker-compose.yml` to declare the composition
- use `docker-compose up` command to bring up the stack

REQUIREMENTS

- The following binaries are required for building and should be put in the `cfdemo2\cf-res\software` folder:
  - `ColdFusion_2016_WWEJ_linux64.bin`
  - `hotfix-004-302561.jar`
  - `mysql-connector-java-5.1.42-bin`
- The `cfbaseos` image should be built if it hasn't been already.

TO BUILD

    cd cfdemo2
    docker build --squash -t cfdemo2 .

FILES OF INTEREST

    Dockerfile
    cf\
    nginx\nginx.conf
    www\
    docker-compose.yml

TO RUN

    docker-compose up

Test by browsing to http://localhost


# Demo 3: Load-Balancing with NGINX and Redis

Load-balancing with NGINX and Redis.
Builds on Demo 2 and demonstrates:

- load balancing with NGINX
- Redis for session sharing
- use the image created in Demo 2
- add a simple layer to the image: Redis configuration (in neo-runtime.xml)
- add a Redis service to the composition using the official Redis image
- have multiple CF containers
- configure NGINX to have multiple backends
- use docker-compose.yml to declare the composition

REQUIREMENTS

- `cfdemo2` image created in Demo 2

TO BUILD

    cd cfdemo3
    docker build -t cfdemo3 .

FILES OF INTEREST

    Dockerfile
    cf\
    nginx\nginx.conf
    www\
    docker-compose.yml

TO RUN

    docker-compose up

Test by browsing to http://localhost. Note the containers are load balanced (thanks to NGINX) and the session id remains the same (thanks to Redis).

AN OPTION when using NGINX for load balancing is to use sticky sessions instead of Redis. NGINX can do this by way of the upstream 'ip_hash' directive. This is a bit tricky though because the client IP is abstracted by the Docker network (NAT). See this issue here:

https://github.com/docker/for-mac/issues/180

You can alternatively however hash on some other client identifier other than IP address like cftoken but it takes at least an initial round trip through the load balancer for new clients to receive a cftoken so in these cases the client may not stick.


# Demo 4: Docker native LB & Scaling

Docker native LB & Scaling.

**docker-compose.yml**

- use the Redis-enabled CF image `cfdemo3` we built in Demo 3
- note the simpler (single `cf` service declaration) in `docker-compose.yml`
- note the upstream backends defined in `nginx.conf` are based on the way Docker automatically names the containers on the network: `cfdemo4_cf_1`, `cfdemo4_cf_2`, etc.

This stack will be composed of:
- an NGINX service (scale=1)
- a Redis service (scale=1)
- a ColdFusion service (scale=5)

REQUIREMENTS

- `cfdemo3` image created in Demo 3

TO BUILD

- Nothing will be built for Demo 4; we are going to reuse the `cfdemo3` Redis-ready image we built in Demo 3.

FILES OF INTEREST

    nginx\nginx.conf (5 backends)
    docker-compose.yml (only one cf service defined this time)

TO RUN

    cd cfdemo4
    docker-compose up --scale cf=5

Test by browsing to http://localhost. Note the containers are load balanced (this time by Docker) and the session id remains the same (thanks to Redis again).