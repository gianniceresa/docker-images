#!/bin/bash

set -e

dbConnString="$1"
shift
cmd="$@"

until java -cp "/opt/oracle/biee/jdbc/lib/ojdbc6.jar:/opt/oracle/" OracleJDBC "$dbConnString" "$BI_CONFIG_RCU_USER as sysdba" "$BI_CONFIG_RCU_PWD"; do
  >&2 echo "Oracle Database is unavailable - sleeping 5 seconds"
  sleep 5
done

>&2 echo "Oracle Database is up - execution command"
exec $cmd
