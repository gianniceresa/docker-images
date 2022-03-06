#!/bin/bash

#
# File: runOAS.sh
# Purpose: Auto start/stop of OAS 5.9.0 in Docker container
# Author: Gianni Ceresa (gianni.ceresa@datalysis.ch), February 2020
# Absolutely no warranty, use at your own risk
# Please include this header in any copy or reuse of the script you make
#

# env variables set by Dockerfile
# ORACLE_BASE=/opt/oracle
# ORACLE_HOME=/opt/oracle/product/<version>
# DOMAIN_HOME=/opt/oracle/config/domains

########### SIGTERM handler ############
function _term() {
  echo "Stopping container."
  echo "SIGTERM received, shutting down OAS!"
  stopOAS;
  # drop RCU on exit?
  if [ "$DROP_RCU_ON_EXIT" = true ]; then
    dropRCU;
  fi;
}

########### SIGKILL handler ############
function _kill() {
  echo "SIGKILL received, shutting down OAS!"
  stopOAS;
  # drop RCU on exit?
  if [ "$DROP_RCU_ON_EXIT" = true ]; then
    dropRCU;
  fi;
}

############# Configure OAS ################
function configureOAS {
  echo "Configure OAS"
  $ORACLE_BASE/_validateRCU.sh
  if [ $? -ne 0 ]; then
    echo "Abort OAS configuration..."
    exit 1
  else
    $ORACLE_BASE/_configureOAS.sh
  fi
}

############# Check OAS ################
function checkOASConfigured {
  # check if /user_projects/domains/$BI_CONFIG_DOMAINE_NAME exists
  if [ -d "$DOMAIN_HOME/$BI_CONFIG_DOMAINE_NAME" ]; then
    echo "1"
  else
    echo "0"
  fi;
}

############# Drop OAS RCU schemas ################
function dropRCU {
  echo "Dropping RCU schemas"
  $ORACLE_BASE/_dropRCU.sh
}

############# Start OAS ################
function startOAS {
  echo "Starting OAS"
  $DOMAIN_HOME/$BI_CONFIG_DOMAINE_NAME/bitools/bin/start.sh
}

############# Stop OAS ################
function stopOAS {
  echo "Stopping OAS"
  $DOMAIN_HOME/$BI_CONFIG_DOMAINE_NAME/bitools/bin/stop.sh
  # delete _WLS_ADMINSERVER000000.DAT and _WLS_BI_SERVER1000000.DAT as they often give issues on restart
  echo "Deleting Weblogic Store files ..."
  rm -f $DOMAIN_HOME/$BI_CONFIG_DOMAINE_NAME/servers/AdminServer/data/store/default/*.DAT
  rm -f $DOMAIN_HOME/$BI_CONFIG_DOMAINE_NAME/servers/bi_server1/data/store/default/*.DAT
}

############# MAIN ################

# Set SIGTERM handler
trap _term SIGTERM

# Set SIGKILL handler
trap _kill SIGKILL

# - BI_CONFIG_DOMAINE_NAME env variable
if [ "$BI_CONFIG_DOMAINE_NAME" == "" ]; then
  BI_CONFIG_DOMAINE_NAME=bi
  echo "BI_CONFIG_DOMAINE_NAME not defined, default: $BI_CONFIG_DOMAINE_NAME"
fi;

# - DROP_RCU_ON_EXIT env variable (default "false")
if [ "$DROP_RCU_ON_EXIT" == "" ]; then
  DROP_RCU_ON_EXIT=false
  echo "DROP_RCU_ON_EXIT not defined, default: $DROP_RCU_ON_EXIT"
else
  echo "DROP_RCU_ON_EXIT defined, value: $DROP_RCU_ON_EXIT"
fi;

# Check whether OAS is already configured
if [ "`checkOASConfigured`" == "0" ]; then
  # Execute the configuration of OAS
  configureOAS;
else
  # Start OAS
  startOAS;
fi;


echo "#########################"
$DOMAIN_HOME/$BI_CONFIG_DOMAINE_NAME/bitools/bin/status.sh
echo "#########################"

tail -f $DOMAIN_HOME/$BI_CONFIG_DOMAINE_NAME/servers/obis1/logs/obis1.out &
childPID=$!
wait $childPID
