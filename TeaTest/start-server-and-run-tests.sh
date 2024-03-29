#!/bin/bash

if [ -z "$1" ]
then
    echo "No test script name supplied"
    exit 1
fi

# Start the server
echo -n `date`
echo " Starting the server"
rm /tmp/server.log /tmp/server-stdout.log 2>/dev/null
IntegrationServer -w /tmp/work --event-log /tmp/server.log > /tmp/server-stdout.log 2>&1 &

# Wait for it to finish initialising
counter=120
echo -n `date`
echo " Polling (for up to two minutes) for server startup to complete"
while [ "$counter" != "0" ]; do
    # Look for the startup finished message:
    # 2019-04-04 08:46:39.205168Z: [Thread 10860] (Msg 1/1) BIP1991I: Integration server has finished initialization.
    grep -q "BIP1991" /tmp/server.log 2>/dev/null
    if [ "$?" != "0" ]; then
#        echo "Server not available"
        sleep 1
    else
        echo -n `date`
        echo " Server is available"
        counter=0
    fi
done

echo -n `date`
echo " Running tests"
$1
rc=$?

echo -n `date`
echo " Killing the test server"
kill -9 %1

echo "Server stdout/err"
cat /tmp/server-stdout.log

echo "Event log"
cat /tmp/server.log

exit $((rc))
