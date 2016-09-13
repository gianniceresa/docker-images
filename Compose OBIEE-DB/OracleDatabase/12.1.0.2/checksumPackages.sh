#!/bin/bash
# 
# Since: September, 2016
# Author: gianni.ceresa@datalysis.ch
# Description: Build script for building Oracle Business Intelligence Docker images.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 
# Copyright (c) 2016 DATAlysis GmbH and/or its affiliates. All rights reserved.
# 

# Validate packages
checksumPackages() {
  echo "Checking if required packages are present and valid..."
  md5sum -c Checksum.md5
  if [ "$?" -ne 0 ]; then
    echo "MD5 for required packages to build this image did not match!"
    echo "Make sure to download missing or invalid files in folder $VERSION."
    exit $?
  fi
}

checksumPackages

