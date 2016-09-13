#!/bin/bash

set -e

dbConnString="$1"
shift
dbPassword="$1"
shift
cmd="$@"

until java -cp "/opt/oracle/ojdbc7.jar:/opt/oracle/" OracleJDBC "$dbConnString" "sys as sysdba" "$dbPassword"; do
  >&2 echo "Oracle Database is unavailable - sleeping"
  sleep 5
done

>&2 echo "Oracle Database is up - execution command"
exec $cmd
