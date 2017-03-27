Oracle BI Baseline Validation Tool
===============
Sample Docker build files to facilitate installation, configuration, and environment setup for DevOps users. For more information about Oracle Business Intelligence please see the Oracle BI Baseline Validation Documentation (included in the zip in the /doc folder).

## How to build and run
This project offers sample Dockerfiles for OBI-BVT.

Before to build the image you first need to [download Oracle BI BVT](http://www.oracle.com/technetwork/middleware/bi/downloads/bi-bvt-download-3587672.html) and place the ZIP file in the same folder of the `Dockerfile`.

### Building Oracle BI Baseline Validation Tool Docker image

To build the image, execute the following command:
``` 
  [oracle@localhost OracleBI-BVT]$ docker build -t oracle/obi-bvt .
```
You can see the newly create image with `docker images`.

### Running Oracle BI Baseline Validation Tool in a Docker container

The container by default execute `bash` as there are multiple things you can do with BVT. To have a look around the options you can start with:
```
  docker run -ti --name bi-bvt oracle/obi-bvt
```
You will end up with a `bash` session inside the container where you can execute BVT by using the following command:
```
  bash-4.2# ./bin/obibvt
  
  Oracle BI Baseline Validation Tool (12.2.1.1.0-1.6.7)

  Usage: obibvt
    -displaytests                   Displays all tests in all installed plugins
    -createconfig <filename>        Creates a default test run configuration XML
    -deployment <deploymentname>    Deployment Target in the Config XML file
                                    that the tests will run against. The -config
                                    argument is also required
    -config <testconfig.xml>        Specify the XML file that describes the test
                                    configuration. -deployment or -compareresults
                                    argument is also required
    -password <password>            The password to be used for UserName
    -compareresults <folder1> <folder2>
                                    Compare results of two test runs. -config is
                                    also required
  Examples:
    bin/obibvt -displaytests
    bin/obibvt -createconfig TestConfig.xml
    bin/obibvt -config TestConfig.xml -deployment PreUpgrade
    bin/obibvt -config TestConfig.xml -deployment PreUpgrade -password <password>
    bin/obibvt -compareresults Results/PreUpgrade Results/PostUpgrade -config TestConfig.xml
```

#### Useful commands
Execute BVT using the UI plugin (opening analysis/dashboard in a browser and taking snapshots) :
```
  xvfb-run ./bin/obibvt -config /opt/BVT/testconfig.xml -deployment PreUpgrade
```
`xvfb-run` is required to provide a virtual graphical environment so that Firefox can be used to take snaptshots.

Load a config file from the host into the container :
```
  docker run -ti --name bi-bvt -v <path_to_your_file>:/opt/config.xml:Z oracle/obi-bvt
```
Then use it for BVT execution :
```
  bash-4.2# xvfb-run ./bin/obibvt -config /opt/config.xml -deployment PreUpgrade
```
The same logic apply to folder if you want to have access from inside the container to a folder containing a previously executed BVT for comparison or also to store the result of BVT into a persistant storage location on the host.
For example :
```
  docker run -d --rm --name bi-bvt -v /home/oracle/BVT/config.xml:/opt/config.xml:Z -v /home/oracle/BVT/Results:/opt/BVT/Results:Z oracle/obi-bvt xvfb-run ./bin/obibvt -config /opt/config.xml -deployment PreUpgrade
```
Will execute BVT in the background and delete the container once done. BVT is executed using the `/home/oracle/BVT/config.xml` file and against the "PreUpgrade" deployment. The result of BVT will be stored in /home/oracle/BVT/Results on the host. The same command can be used for a different deployment and finally use another container to compare the results.

## Support
Currently Oracle BI BVT on Docker is **NOT** supported by Oracle (AFAIK). Use these files at your own discretion.

## License
To download and run Oracle BI Baseline Validation Tool, regardless whether inside or outside a Docker container, you must download the archive from the Oracle website and accept the license indicated at that page.

All scripts and files hosted in this project and GitHub [docker-images/OracleBI-BVT](./) repository required to build the Docker images are, unless otherwise noted, released under the Common Development and Distribution License (CDDL) 1.0 and GNU Public License 2.0 licenses.

## Copyright
Copyright (c) 2017 [DATAlysis GmbH](https://datalysis.ch). All rights reserved.
