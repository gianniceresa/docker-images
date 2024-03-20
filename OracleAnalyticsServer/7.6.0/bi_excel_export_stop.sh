#!/bin/bash

JS_SCRIPT=${ORACLE_HOME}/bi/modules/oracle.bi.tech/obitech-serverside-exportexcel-bundle.js


# Stop process
excelAppPID=$(pgrep -f "${JS_SCRIPT}")
if [ $? != 0 ]; then
  excelAppPID=""
fi
  
if [ -n "${excelAppPID}" ]; then
  echo "Stopping Export excel App with pid: ${excelAppPID}; killing (SIGTERM) ..."
  kill $excelAppPID
fi
