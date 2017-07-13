Apache Zeppelin & Oracle PGX
===============
Sample Docker build files to facilitate usage of PGX by packaging it with [Apache Zeppelin](http://zeppelin.apache.org/). For more information about Oracle Labs Parallel Graph AnalytiX (PGX) toolkit please see the [Oracle PGX official page](http://www.oracle.com/technetwork/oracle-labs/parallel-graph-analytix/overview/index.html).

## How to build and run
This project offers sample Dockerfiles for Apache Zeppelin 0.7.2 and PGX 2.4.1 OTN version.

**IMPORTANT:** Before to build the image you need to download the PGX Server install file  and the PGX Zeppelin interpreter from the official [Oracle page](http://www.oracle.com/technetwork/oracle-labs/parallel-graph-analytix/downloads/index.html). Place the `pgx-2.4.1-server.zip` and `pgx-2.4.1-zeppelin-interpreter.zip` files in the same directory as the Dockerfile. You also have to make sure to have internet connectivity for apt-get.

### Build the image
To build the Docker image execute the followin command:
```
  [oracle@localhost dockerfiles]$ docker build --force-rm=true --no-cache=true -t apache/zeppelin:0.7.2-pgx .
```
You can replace "apache/zeppelin:0.7.2-pgx" by any other tag you want to associate to the image (this is the name you use to reference the image when creating a new container).

### Run Apache Zeppelin & PGX server
The container will automatically start PGX server and Apache Zeppelin. The Zeppelin PGX interpreter is already configured to connect to the PGX server.

```
  docker run -d \
             --name zeppelin \
             -p 8080:8080 -p 7007:7007 \
             apache/zeppelin:0.7.2-pgx
  
  Parameters:
     --name : The name of the container itself
     -p :     The port mapping of the host port to the container port. -P can be used for automatic mapping to random ports     
``` 
Once the container has been started you can connect to Zeppelin by using the URL http://localhost:8080 (replace *localhost* with the IP/address of the Docker host).

#### Stop / Restart of Apache Zeppelin - PGX
Once the **docker run** has been used to create a container it's possible to easily stop it with the following command:
```
 docker stop <container-id>
```
To start the container again simply use:
```
  docker start <container-id>
```
Data inside the container will be preserver between stop/start (notebooks will not be lost).

#### Useful commands
List the ports exposed by the container and the links with the hosts ports (useful when using the -P with automatic port mapping) :
```
  docker port <container-id>
```
Display the "live" output from the container (a log file) :
```
  docker logs -f <container-id>
```
Open an interactive bash into the container :
```
  docker exec -it <container-id> bash
```

## Support
Currently Oracle PGX on Docker is **NOT** supported by Oracle (maybe coming in the future). Use these files at your own discretion.

## License
To download and use PGX, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page.

All scripts and files hosted in this project required to build the Docker images are, unless otherwise noted, released under the Common Development and Distribution License (CDDL) 1.0 and GNU Public License 2.0 licenses.

## Copyright
Copyright (c) 2017 [DATAlysis GmbH](https://datalysis.ch). All rights reserved.
