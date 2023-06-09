#!/bin/bash
#
#
# Copyright (c) 2016-2017 LabKey Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Simple script to
#   1. Monitor if Tomcat process is running. If not, stop the container
#   2. Listen for incoming SIGNALS from docker daemon and handle
#      them properly.
#

stop_labkey()
{

    #
    # Stop Tomcat:
    #
    # If Tomcat process is not running, then skip step
    PID=$(/bin/ps ax | grep bootstrap.jar | grep catalina)
    if [ -n "$PID" ]
    then
        echo "TOMCAT: Stopping Tomcat Server"
        INSTALLDIR=/labkey/apps/tomcat

        # Start Tomcat Server
        if ! /labkey/bin/start_tomcat.sh stop
        then
            echo "WARNING: TOMCAT did not stop in a timely fashion"
        fi
    fi

    exit "$TOMCAT_RUNNING"

}

#
# This script will listen for SIGINT and SIGTERM signals
# and execute stop_labkey function if they are recieved.
#
# SIGINT signal will be sent to this process when an administrator runs "docker stop:
# SIGTERM signal will be sent to this process when and administator
#   * runs "docker kill" or
#   * if the SIGINT signal sent by "docker stop" does to successful stop the terminal
#     after 30s
#
trap stop_labkey SIGINT SIGTERM


#
# Monitor Tomcat process. If Tomcat stops running for
# any reason, run the stop_labkey function to stop the container
#
TOMCAT_RUNNING=0
PID=$(/bin/ps ax | grep bootstrap.jar | grep catalina)
if [ -n "$PID" ]
then
    sleep 10
    while [ ${TOMCAT_RUNNING} -eq 0 ]
    do
        PID=$(/bin/ps ax | grep bootstrap.jar | grep catalina)
        if [ -n "$PID" ]
        then
            sleep 10
            TOMCAT_RUNNING=0
        else
            TOMCAT_RUNNING=1
            stop_labkey
        fi
    done
else
    TOMCAT_RUNNING=1
    stop_labkey
fi

TOMCAT_RUNNING=1
stop_labkey
