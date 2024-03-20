#!/bin/bash

LOG_DIR=${BI_EXCEL_EXPORT}
JS_SCRIPT=${ORACLE_HOME}/bi/modules/oracle.bi.tech/obitech-serverside-exportexcel-bundle.js


# Start process
"nohup" "node" "${JS_SCRIPT}" > ${LOG_DIR}/biexportexcel.log &

# Check if process started...
i=0
max_attempts=60
excelAppPID=0
echo "Export excel app is starting..."
while [[ i < max_attempts ]];
do
  excelAppPID=$(pgrep -f "${JS_SCRIPT}")
  if [ $? != 0 ]; then
    i=$((i+1))
    sleep 1
  else
    echo "Export excel app is running with pid: ${excelAppPID}"
    exit 0
  fi
done
echo "Export excel app failed to start after 60 seconds"
exit 1
