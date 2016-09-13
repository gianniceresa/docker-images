Oracle Business Intelligence
===============
Sample Docker build files to facilitate installation, configuration, and environment setup for DevOps users. For more information about Oracle Business Intelligence please see the [Oracle Business Intelligence Documentation](http://docs.oracle.com/middleware/12211/index.html).

## How to build and run
This project offers sample Dockerfiles for OBIEE 12c (12.2.1.0.0 and 12.2.1.1.0). To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that performs MD5 checks and is an easy way for beginners to get started. Expert users are welcome to directly call `docker build` with their prefered set of parameters.

### Building Oracle Business Intelligence Docker Install Images
**IMPORTANT:** You will have to provide the installation binaries of Oracle Business Intelligence and put them into the `<version>` folder. You only need to provide the binaries for the version you are going to install. You also have to make sure to have internet connectivity for yum. You also need to provide the RPM of the Oracle JDK version you want to use.

Before you build the image make sure that you have provided the installation binaries and put them into the right folder. Once you have chosen which version you want to build an image of, run the **buildDockerImage.sh** script as root or with `sudo` privileges:
```
  [oracle@localhost dockerfiles]$ ./buildDockerImage.sh -h
  
  Usage: buildDockerImage.sh -v [version] [-i]
  Builds a Docker Image for Oracle Business Intelligence.
  
  Parameters:
     -v: version to build
         Choose one of: 12.2.1.0.0  12.2.1.1.0
     -i: ignores the MD5 checksums
  
  LICENSE CDDL 1.0 + GPL 2.0
  
  Copyright (c) 2016 DATAlysis GmbH. All rights reserved.
```
**IMPORTANT:** The resulting images will be an image with the Weblogic and BI installed. On first startup of the container the BI configuration (domain, RCU, etc.) will be executed.

### Running Oracle Business Intelligence in a Docker container

#### First run of Oracle Business Intelligence in a Docker container
To run your OBIEE Docker image use the **docker run** command as follows:
```
  docker run --name obiee -p 9500-9514:9500-9514 -p 9799:9799 --env-file ./12.2.1.1.0/bi_config_param.env --link <your DB container name> oracle/obiee:12.2.1.1.0
  
  Parameters:
     --name:     The name of the container itself
     -p:         The port mapping of the host port to the container port.
     --env-file: Path to the file containing the BI configuration parameters (RCU, domain etc.)
     --link:     If the database for the RCU is a docker container link it to the OBIEE container. *Not needed if not using a container based database*
     -e VARIABLE_NAME=variable_value : Allow to override values coming from the linked env-file.
``` 
Once the container has been started and OBIEE configured and started you can connect to it just like to any other OBIEE:
```
  http://localhost:9500/console
  http://localhost:9500/em
  http://localhost:9502/analytics
```
