#!/bin/bash

#
# File: _dropRCU.sh
# Purpose: Drop the RCU schemas of OAS 5.9.0 in Docker container
# Author: Gianni Ceresa (gianni.ceresa@datalysis.ch), February 2020
# Absolutely no warranty, use at your own risk
# Please include this header in any copy or reuse of the script you make
#

# env variables set by Dockerfile
# ORACLE_BASE=/opt/oracle
# ORACLE_HOME=/opt/oracle/product/<version>
# DOMAIN_HOME=/opt/oracle/config/domains

#
# set values based on env variables or default values
#

# - BI_CONFIG_RCU_DBSTRING
if [ "$BI_CONFIG_RCU_DBSTRING" == "" ]; then
  echo "BI_CONFIG_RCU_DBSTRING not defined, can't drop RCU schemas"
  exit 1
fi;

# - BI_CONFIG_RCU_USER
if [ "$BI_CONFIG_RCU_USER" == "" ]; then
  BI_CONFIG_RCU_USER=sys
  echo "BI_CONFIG_RCU_USER not defined, default: $BI_CONFIG_RCU_USER"
fi;

# - BI_CONFIG_RCU_PWD
if [ "$BI_CONFIG_RCU_PWD" == "" ]; then
  echo "BI_CONFIG_RCU_PWD not defined, can't drop RCU schemas"
  exit 1
fi;

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

# database connection params
DBCONN_PARAM=""
DBCONN_PARAM="$DBCONN_PARAM -connectString $BI_CONFIG_RCU_DBSTRING"
DBCONN_PARAM="$DBCONN_PARAM -dbUser $BI_CONFIG_RCU_USER"
DBCONN_PARAM="$DBCONN_PARAM -databaseType ORACLE"
DBCONN_PARAM="$DBCONN_PARAM -dbRole SYSDBA"

# components params
COMPONENTS=""
COMPONENTS="$COMPONENTS -component STB"
COMPONENTS="$COMPONENTS -component MDS"
COMPONENTS="$COMPONENTS -component WLS"
COMPONENTS="$COMPONENTS -component OPSS"
COMPONENTS="$COMPONENTS -component BIPLATFORM"
COMPONENTS="$COMPONENTS -component IAU"
COMPONENTS="$COMPONENTS -component IAU_APPEND"
COMPONENTS="$COMPONENTS -component IAU_VIEWER"

# RCU settings
RCU_SETTINGS=""
RCU_SETTINGS="$RCU_SETTINGS -dropRepository"
RCU_SETTINGS="$RCU_SETTINGS -silent"
RCU_SETTINGS="$RCU_SETTINGS -schemaPrefix $BI_CONFIG_RCU_DB_PREFIX"
RCU_SETTINGS="$RCU_SETTINGS $DBCONN_PARAM"
RCU_SETTINGS="$RCU_SETTINGS $COMPONENTS"

#
# validate RCU drop command and settings 
#
$ORACLE_HOME/oracle_common/bin/rcu $RCU_SETTINGS -validate <<< $BI_CONFIG_RCU_PWD

if [ $? -ne 0 ]; then
  echo "ERROR validating RCU command and settings, can't drop RCU schemas"
  echo "command: $ORACLE_HOME/oracle_common/bin/rcu $RCU_SETTINGS -validate <<< '$BI_CONFIG_RCU_PWD'"
  exit 1
fi

#
# drop RCU schemas
#
$ORACLE_HOME/oracle_common/bin/rcu $RCU_SETTINGS <<< $BI_CONFIG_RCU_PWD

