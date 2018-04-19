Oracle Business Intelligence
===============
Sample Docker build files to facilitate installation, configuration, and environment setup for DevOps users. For more information about Oracle Business Intelligence please see the [Oracle Business Intelligence Documentation](http://docs.oracle.com/middleware/12213/index.html).

## How to build and run
This project offers sample Dockerfiles for OBIEE 12c (12.2.1.0.0, 12.2.1.1.0, 12.2.1.2.0, 12.2.1.3.0 and 12.2.1.4.0). To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that performs MD5 checks and is an easy way for beginners to get started. Expert users are welcome to directly call `docker build` with their prefered set of parameters.

### Building Oracle Business Intelligence Docker Install Images
**IMPORTANT:** You will have to provide the installation binaries of Oracle Business Intelligence and put them into the `<version>` folder. You only need to provide the binaries for the version you are going to install. You also have to make sure to have internet connectivity for yum. You also need to provide the RPM of the Oracle JDK version you want to use.

Before you build the image make sure that you have provided the installation binaries and put them into the right folder. Once you have chosen which version you want to build an image of, run the **buildDockerImage.sh** script as root or with `sudo` privileges (if your user isn't allowed to execute docker directly):
```
  [oracle@localhost dockerfiles]$ ./buildDockerImage.sh -h
  
  Usage: buildDockerImage.sh -v [version] [-i]
  Builds a Docker Image for Oracle Business Intelligence.
  
  Parameters:
     -v: version to build
         Choose one of: 12.2.1.0.0  12.2.1.1.0  12.2.1.2.0  12.2.1.3.0  12.2.1.4.0
     -i: ignores the MD5 checksums
  
  LICENSE CDDL 1.0 + GPL 2.0
  
  Copyright (c) 2016 DATAlysis GmbH. All rights reserved.
```
**IMPORTANT:** The resulting images will be an image with Weblogic and BI installed. On first startup of the container the BI configuration (domain, RCU, etc.) will be executed.

### Running Oracle Business Intelligence in a Docker container

#### First run of Oracle Business Intelligence in a Docker container
The first execution will be longer than next stop/start because OBIEE must be configured. Many parameters can be adjusted and 2 are mandatory to run the image or it will fail.
To run your OBIEE Docker image use the **docker run** command as follows:
```
  docker run --name obiee \
             -p 9500-9514:9500-9514 -p 9799:9799 \
             --stop-timeout 600 \
             -e "BI_CONFIG_RCU_DBSTRING=192.168.120.80:1521:orclpdb1" \
             -e "BI_CONFIG_RCU_PWD=Admin123" \
             oracle/obiee:12.2.1.4.0
  
  Parameters:
     --name :         The name of the container itself
     -p :             The port mapping of the host port to the container port. -P can be used for automatic mapping to random ports
     --stop-timeou t: Override the default timeout when a container stop. OBIEE requires longer for a clean shutdown
     -e VARIABLE_NAME=variable_value : Define some variables used to configure and run the container.
     
  Mandatory variables:
     - BI_CONFIG_RCU_DBSTRING : DB connection string for RCU, format: hostname:port:servicename
     - BI_CONFIG_RCU_PWD :      password for the account with sysdba privileges to create new schemas
     
     Additional available variables listed at the end of the page.
     
``` 
Once the container has been started and OBIEE configured and started you can connect to it just like to any other OBIEE:
```
  http://localhost:9500/console
  http://localhost:9500/em
  http://localhost:9502/analytics
```

#### Stop / Start of Oracle Business Intelligence after first execution
Once the **docker run** has been used to configure OBIEE and start it for the first time it's possible to easily stop it with the following command:
```
 docker stop <container-id>
```
To start the container again simply use:
```
  dockr start <container-id>
```

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
Display status and ports used by components of OBIEE :
```
  docker exec <container-id> /opt/oracle/biee/user_projects/domains/bi/bitools/bin/status.sh -v
```
Run an ephemeral OBIEE container which will drop RCU and will be destroyed when stopped :
```
  docker run -d -P --rm \
             --stop-timeout 600 \
             -e "BI_CONFIG_RCU_DBSTRING=192.168.120.80:1521:orclpdb1" \
             -e "BI_CONFIG_RCU_PWD=Admin123" \
             -e "DROP_RCU_ON_EXIT=true" \
             oracle/obiee:12.2.1.4.0
```

#### Available variables
The following variable are not mandatory as they all have a default value and the configuration of OBIEE can be done without, but you can freely override their value to match your needs.
```
  BI_CONFIG_DOMAINE_NAME   : domain name, by default "bi"
  BI_CONFIG_ADMIN_USER     : OBIEE admin username, by default "weblogic"
  BI_CONFIG_ADMIN_PWD      : OBIEE admin password, by default "Admin123"
  BI_CONFIG_RCU_USER       : sysdba user to create RCU schemas, by default "sys"
  BI_CONFIG_RCU_DB_PREFIX  : prefix for the RCU schemas, by default unique value based on the container unique hash
  BI_CONFIG_RCU_NEW_DB_PWD : password for the newly created RCU schemas, by default "Admin123"
  DROP_RCU_ON_EXIT         : if "true" the RCU schemas will be dropped when stopping OBIEE, by default "false"
```

## Support
Currently Oracle Business Intelligence on Docker is **NOT** supported by Oracle (maybe coming in the future). Use these files at your own discretion.

## License
To download and run Oracle Business Intelligence, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page.

All scripts and files hosted in this project and GitHub [docker-images/OracleBIEE](./) repository required to build the Docker images are, unless otherwise noted, released under the Common Development and Distribution License (CDDL) 1.0 and GNU Public License 2.0 licenses.

## Copyright
Copyright (c) 2016 [DATAlysis GmbH](https://datalysis.ch). All rights reserved.
