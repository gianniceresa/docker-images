#!/bin/bash

########### SIGTERM handler ############
function _term() {
   echo "Stopping container."
   echo "SIGTERM received, shutting down OBIEE!"
   ###ORACLE_HOME###/user_projects/domains/###OBIEE_DOMAIN###/bitools/bin/stop.sh
}

########### SIGKILL handler ############
function _kill() {
   echo "SIGKILL received, shutting down OBIEE!"
   ###ORACLE_HOME###/user_projects/domains/###OBIEE_DOMAIN###/bitools/bin/stop.sh
}

############# Configure OBIEE ################
function configureOBIEE {
   echo "### must configure OBIEE ###"
   ###ORACLE_HOME###/bi/bin/config.sh -silent -responseFile ###ORACLE_BASE###/bi_config.rsp -invPtrLoc ###ORACLE_BASE###/oraInst.loc
}

############# Check OBIEE ################
function checkOBIEEConfigured {
   # check if /user_projects/domains/###OBIEE_DOMAIN### exists
   if [ -d "###ORACLE_HOME###/user_projects/domains/###OBIEE_DOMAIN###" ]; then
      echo "1";
   else
      echo "0";
   fi;
}

############# Start OBIEE ################
function startOBIEE {
   ###ORACLE_HOME###/user_projects/domains/###OBIEE_DOMAIN###/bitools/bin/start.sh
}

############# MAIN ################

# Set SIGTERM handler
trap _term SIGTERM

# Set SIGKILL handler
trap _kill SIGKILL

# Default for ORACLE_HOME
if [ "$ORACLE_HOME" == "" ]; then
   export ORACLE_HOME=###ORACLE_HOME###
fi;

# Check whether OBIEE is already configured
if [ "`checkOBIEEConfigured`" == "0" ]; then
   configureOBIEE;
else
   startOBIEE;
fi;


echo "#########################"
###ORACLE_HOME###/user_projects/domains/###OBIEE_DOMAIN###/bitools/bin/status.sh
echo "#########################"

tail -f ###ORACLE_HOME###/user_projects/domains/###OBIEE_DOMAIN###/servers/obis1/logs/obis1.out &
childPID=$!
wait $childPID

