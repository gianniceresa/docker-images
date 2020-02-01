#!/bin/bash
# 
# Since: February, 2020
# Author: Gianni Ceresa <gianni.ceresa@datalysis.ch>
# Description: Build script for building Oracle Analytics Server Docker images.
# Based on https://github.com/oracle/docker-images/tree/master/OracleDatabase
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 
# Copyright (c) 2020 DATAlysis LLC (https://datalysis.ch). All rights reserved.
# 

usage() {
cat << EOF

Usage: buildDockerImage.sh -v [version] [-i]
Builds a Docker Image for Oracle Analytics Server.
  
Parameters:
   -v: version to build
       Choose one of: $(for i in $(ls -d */); do echo -n "${i%%/}  "; done)
   -i: ignores the MD5 checksums

LICENSE CDDL 1.0 + GPL 2.0

Copyright (c) 2020 DATAlysis LLC <https://datalysis.ch>. All rights reserved.

EOF
exit 0
}

# Validate packages
checksumPackages() {
  echo "Checking if required packages are present and valid..."
  md5sum -c Checksum.md5
  if [ "$?" -ne 0 ]; then
    echo "MD5 for required packages to build this image did not match!"
    echo "Make sure to download missing files in folder $VERSION."
    exit $?
  fi
}

if [ "$#" -eq 0 ]; then usage; fi

# Parameters
VERSION="5.5.0"
SKIPMD5=0
DOCKEROPS=""

while getopts "hiv:" optname; do
  case "$optname" in
    "h")
      usage
      ;;
    "i")
      SKIPMD5=1
      ;;
    "v")
      VERSION="$OPTARG"
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options inside buildDockerImage.sh"
      ;;
  esac
done

# Oracle Database Image Name
IMAGE_NAME="oracle/oas:$VERSION"

# Go into version folder
cd $VERSION

if [ ! "$SKIPMD5" -eq 1 ]; then
  checksumPackages
else
  echo "Ignored MD5 checksum."
fi

echo "====================="

# Proxy settings
PROXY_SETTINGS=""
if [ "${http_proxy}" != "" ]; then
  PROXY_SETTINGS="$PROXY_SETTINGS --build-arg=\"http_proxy=${http_proxy}\""
fi

if [ "${https_proxy}" != "" ]; then
  PROXY_SETTINGS="$PROXY_SETTINGS --build-arg=\"https_proxy=${https_proxy}\""
fi

if [ "${ftp_proxy}" != "" ]; then
  PROXY_SETTINGS="$PROXY_SETTINGS --build-arg=\"ftp_proxy=${ftp_proxy}\""
fi

if [ "${no_proxy}" != "" ]; then
  PROXY_SETTINGS="$PROXY_SETTINGS --build-arg=\"no_proxy=${no_proxy}\""
fi

if [ "$PROXY_SETTINGS" != "" ]; then
  echo "Proxy settings were found and will be used during build."
fi

# ################## #
# BUILDING THE IMAGE #
# ################## #
echo "Building image '$IMAGE_NAME' ..."

# BUILD THE IMAGE (replace all environment variables)
BUILD_START=$(date '+%s')
docker build --force-rm=true --no-cache=true $DOCKEROPS $PROXY_SETTINGS -t $IMAGE_NAME -f Dockerfile . || {
  echo "There was an error building the image."
  exit 1
}
BUILD_END=$(date '+%s')
BUILD_ELAPSED=`expr $BUILD_END - $BUILD_START`

echo ""

if [ $? -eq 0 ]; then
cat << EOF
  Oracle Analytics Server Docker Image version $VERSION is ready to be extended: 
    
    --> $IMAGE_NAME

  Build completed in $BUILD_ELAPSED seconds.
  
EOF

else
  echo "Oracle Analytics Server Docker Image was NOT successfully created. Check the output and correct any reported problems with the docker build operation. (clean up temporary images)"
fi
