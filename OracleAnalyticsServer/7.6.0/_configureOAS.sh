#!/bin/bash

#
# File: _configureOAS.sh
# Purpose: Execute the configuration of OAS in Docker container
# Author: Gianni Ceresa (gianni.ceresa@datalysis.ch), February 2020
# Absolutely no warranty, use at your own risk
# Please include this header in any copy or reuse of the script you make
#

# env variables set by Dockerfile
# ORACLE_BASE=/opt/oracle
# ORACLE_HOME=/opt/oracle/product/<version>
# DOMAIN_HOME=/opt/oracle/config/domains

RSP_FILE=$ORACLE_BASE/oas_config.rsp
ORAINV_LOC=$ORACLE_BASE/oraInst.loc

# if RSP file not found error
if [ ! -f $RSP_FILE ]; then
  echo "Response file not found [$RSP_FILE]"
  exit 1
fi

# if OraInventory location file not found error
if [ ! -f $ORAINV_LOC ]; then
  echo "OraInventory location file not found [$ORAINV_LOC]"
  exit 1
fi

#
# set values in RSP file based on env variables or default values
#

# - ORACLE_HOME
sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" $RSP_FILE

# - DOMAIN_HOME
sed -i -e "s|###DOMAIN_HOME###|$DOMAIN_HOME|g" $RSP_FILE

# - BI_CONFIG_DOMAINE_NAME
if [ "$BI_CONFIG_DOMAINE_NAME" == "" ]; then
  BI_CONFIG_DOMAINE_NAME=bi
  echo "BI_CONFIG_DOMAINE_NAME not defined, default: $BI_CONFIG_DOMAINE_NAME"
fi;
sed -i -e "s|###BI_CONFIG_DOMAINE_NAME###|$BI_CONFIG_DOMAINE_NAME|g" $RSP_FILE

# - BI_CONFIG_ADMIN_USER
if [ "$BI_CONFIG_ADMIN_USER" == "" ]; then
  BI_CONFIG_ADMIN_USER=weblogic
  echo "BI_CONFIG_ADMIN_USER not defined, default: $BI_CONFIG_ADMIN_USER"
fi;
sed -i -e "s|###BI_CONFIG_ADMIN_USER###|$BI_CONFIG_ADMIN_USER|g" $RSP_FILE

# - BI_CONFIG_ADMIN_PWD
if [ "$BI_CONFIG_ADMIN_PWD" == "" ]; then
  BI_CONFIG_ADMIN_PWD=Admin123
  echo "BI_CONFIG_ADMIN_PWD not defined, default: $BI_CONFIG_ADMIN_PWD"
fi;
sed -i -e "s|###BI_CONFIG_ADMIN_PWD###|$BI_CONFIG_ADMIN_PWD|g" $RSP_FILE

# - BI_CONFIG_RCU_DBSTRING
if [ "$BI_CONFIG_RCU_DBSTRING" == "" ]; then
  echo "BI_CONFIG_RCU_DBSTRING not defined, can't configure OAS"
  exit 1
fi;
sed -i -e "s|###BI_CONFIG_RCU_DBSTRING###|$BI_CONFIG_RCU_DBSTRING|g" $RSP_FILE

# - BI_CONFIG_RCU_USER
if [ "$BI_CONFIG_RCU_USER" == "" ]; then
  BI_CONFIG_RCU_USER=sys
  echo "BI_CONFIG_RCU_USER not defined, default: $BI_CONFIG_RCU_USER"
fi;
sed -i -e "s|###BI_CONFIG_RCU_USER###|$BI_CONFIG_RCU_USER|g" $RSP_FILE

# - BI_CONFIG_RCU_PWD
if [ "$BI_CONFIG_RCU_PWD" == "" ]; then
  echo "BI_CONFIG_RCU_PWD not defined, can't configure OAS"
  exit 1
fi;
sed -i -e "s|###BI_CONFIG_RCU_PWD###|$BI_CONFIG_RCU_PWD|g" $RSP_FILE

# - BI_CONFIG_RCU_DB_PREFIX
if [ "$BI_CONFIG_RCU_DB_PREFIX" == "" ]; then
  BI_CONFIG_RCU_DB_PREFIX=$(hostname -f)
  # DB prefix must start with a letter: replace first digit with 'G-P' (not hexa chars)
  case ${BI_CONFIG_RCU_DB_PREFIX:0:1} in
    0)
      BI_CONFIG_RCU_DB_PREFIX="g"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    1)
      BI_CONFIG_RCU_DB_PREFIX="h"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    2)
      BI_CONFIG_RCU_DB_PREFIX="i"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    3)
      BI_CONFIG_RCU_DB_PREFIX="j"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    4)
      BI_CONFIG_RCU_DB_PREFIX="k"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    5)
      BI_CONFIG_RCU_DB_PREFIX="l"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    6)
      BI_CONFIG_RCU_DB_PREFIX="m"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    7)
      BI_CONFIG_RCU_DB_PREFIX="n"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    8)
      BI_CONFIG_RCU_DB_PREFIX="o"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
    9)
      BI_CONFIG_RCU_DB_PREFIX="p"${BI_CONFIG_RCU_DB_PREFIX:1:11}
      ;;
  esac
  echo "BI_CONFIG_RCU_DB_PREFIX not defined, default: $BI_CONFIG_RCU_DB_PREFIX"
fi;
sed -i -e "s|###BI_CONFIG_RCU_DB_PREFIX###|$BI_CONFIG_RCU_DB_PREFIX|g" $RSP_FILE

# - BI_CONFIG_RCU_DB_PREFIX
if [ "$BI_CONFIG_RCU_NEW_DB_PWD" == "" ]; then
  BI_CONFIG_RCU_NEW_DB_PWD=Admin123
  echo "BI_CONFIG_RCU_NEW_DB_PWD not defined, default: $BI_CONFIG_RCU_NEW_DB_PWD"
fi;
sed -i -e "s|###BI_CONFIG_RCU_NEW_DB_PWD###|$BI_CONFIG_RCU_NEW_DB_PWD|g" $RSP_FILE

#
# execute configuration
#
$ORACLE_HOME/bi/bin/config.sh -silent -responseFile $RSP_FILE -invPtrLoc $ORACLE_BASE/oraInst.loc

