#!/bin/bash

########### SIGTERM handler ############
function _term() {
   echo "Stopping container."
   echo "SIGTERM received, shutting down OBIEE!"
   ###ORACLE_HOME###/user_projects/domains/$BI_CONFIG_DOMAINE_NAME/bitools/bin/stop.sh
}

########### SIGKILL handler ############
function _kill() {
   echo "SIGKILL received, shutting down OBIEE!"
   ###ORACLE_HOME###/user_projects/domains/$BI_CONFIG_DOMAINE_NAME/bitools/bin/stop.sh
}

############# Configure OBIEE ################
function configureOBIEE {
   ###ORACLE_HOME###/bi/bin/config.sh -silent -responseFile ###ORACLE_BASE###/bi_config.rsp -invPtrLoc ###ORACLE_BASE###/oraInst.loc
}

############# Check OBIEE ################
function checkOBIEEConfigured {
   # check if /user_projects/domains/$BI_CONFIG_DOMAINE_NAME exists
   if [ -d "###ORACLE_HOME###/user_projects/domains/$BI_CONFIG_DOMAINE_NAME" ]; then
      echo "1";
   else
      echo "0";
   fi;
}

############# Replace config values in RSP file #############
function customizeRSP {
   sed -i -e "s|###BI_CONFIG_DOMAINE_NAME###|$BI_CONFIG_DOMAINE_NAME|g"     ###ORACLE_BASE###/bi_config.rsp
   sed -i -e "s|###BI_CONFIG_ADMIN_USER###|$BI_CONFIG_ADMIN_USER|g"         ###ORACLE_BASE###/bi_config.rsp
   sed -i -e "s|###BI_CONFIG_ADMIN_PWD###|$BI_CONFIG_ADMIN_PWD|g"           ###ORACLE_BASE###/bi_config.rsp
   sed -i -e "s|###BI_CONFIG_RCU_DBSTRING###|$BI_CONFIG_RCU_DBSTRING|g"     ###ORACLE_BASE###/bi_config.rsp
   sed -i -e "s|###BI_CONFIG_RCU_USER###|$BI_CONFIG_RCU_USER|g"             ###ORACLE_BASE###/bi_config.rsp
   sed -i -e "s|###BI_CONFIG_RCU_PWD###|$BI_CONFIG_RCU_PWD|g"               ###ORACLE_BASE###/bi_config.rsp
   sed -i -e "s|###BI_CONFIG_RCU_DB_PREFIX###|$BI_CONFIG_RCU_DB_PREFIX|g"   ###ORACLE_BASE###/bi_config.rsp
   sed -i -e "s|###BI_CONFIG_RCU_NEW_DB_PWD###|$BI_CONFIG_RCU_NEW_DB_PWD|g" ###ORACLE_BASE###/bi_config.rsp
}

############# Start OBIEE ################
function startOBIEE {
   ###ORACLE_HOME###/user_projects/domains/$BI_CONFIG_DOMAINE_NAME/bitools/bin/start.sh
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
   # Replace placeholders in the config RSP file with provided values
   customizeRSP;
   # Execute the configuration of OBIEE
   configureOBIEE;
else
   startOBIEE;
fi;


echo "#########################"
###ORACLE_HOME###/user_projects/domains/$BI_CONFIG_DOMAINE_NAME/bitools/bin/status.sh
echo "#########################"

tail -f ###ORACLE_HOME###/user_projects/domains/$BI_CONFIG_DOMAINE_NAME/servers/obis1/logs/obis1.out &
childPID=$!
wait $childPID

