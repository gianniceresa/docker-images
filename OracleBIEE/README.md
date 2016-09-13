Oracle Business Intelligence
===============
Sample Docker build files to facilitate installation, configuration, and environment setup for DevOps users. For more information about Oracle Business Intelligence please see the [Oracle Business Intelligence Documentation](http://docs.oracle.com/middleware/12211/index.html).

## How to build and run
This project offers sample Dockerfiles for OBIEE 12c (12.2.1.0.0 and 12.2.1.1.0). To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that performs MD5 checks and is an easy way for beginners to get started. Expert users are welcome to directly call `docker build` with their prefered set of parameters.
