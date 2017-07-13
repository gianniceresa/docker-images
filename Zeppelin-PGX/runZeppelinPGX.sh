#!/bin/bash

# Start PGX Server
$PGX_HOME/$PGX_VERSION/bin/start-server >> $PGX_HOME/${PGX_VERSION}-server.log 2>&1 &

tail -f $PGX_HOME/${PGX_VERSION}-server.log &
childPID=$!

# Start Zeppelin
/usr/bin/tini -- /zeppelin/bin/zeppelin.sh &

# keep running forever
wait $childPID
