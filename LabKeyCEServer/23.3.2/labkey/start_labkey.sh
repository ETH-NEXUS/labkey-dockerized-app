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

# Start X Virtual Frame Buffer, PostgreSQL and Tomcat Services
#
# This entry point script will perform the following steps
# 1) Read secrets
#   - The required secrets are password for accessing LabKey database on PostgreSQL server
#     and Master Encryption Key used to access LabKey PropertyStore
#   - The secrets must be provided at RUN time using ENV variables
#       * PG_PASSWORD
#       * LABKEY_ENCRYPTION_KEY
# 2) Start X virtual frame buffer (required for R reports)
# 3) Start PostgreSQL Server and create "labkey" user
# 4) Using secrets read above start Tomcat server
#

#
# Read Secrets into variables to be used later in script
#
echo "Secrets: Reading secrets (ie passwords, etc) from environment"
if [ -z "$PG_PASSWORD" ]
then
    echo "ERROR: PG_PASSWORD environment variable does not exist. This is required to start LabKey Server"
    exit 1
else
    POSTGRESQL_PASSWORD="$PG_PASSWORD"
fi

if [ -z "$LABKEY_ENCRYPTION_KEY" ]
then
    echo "ERROR: LABKEY_ENCRYPTION_KEY environment variable does not exist. This is required to start LabKey Server"
    exit 1
else
    MASTER_ENC_KEY="$LABKEY_ENCRYPTION_KEY"
fi

#
# Start Tomcat
#

# Customize configuration files using EVN variables
echo "TOMCAT: Starting Tomcat Server to run LabKey Server application"
INSTALLDIR=/labkey/apps/tomcat
TOMCAT_HOME=/labkey/apps/tomcat

# Customize LabKey configuration file
sed -i s/'@@PG_USER@@'/"$PG_USER"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml
sed -i s/'@@PG_PASSWORD@@'/"$POSTGRESQL_PASSWORD"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml
sed -i s/'@@ENCRYPTION_KEY@@'/"$MASTER_ENC_KEY"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml
sed -i s/'@@PG_HOST@@'/"$PG_HOST"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml
sed -i s/'@@PG_DATABASE@@'/"$PG_DATABASE"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml
sed -i s/'@@LK_SMTP_HOST@@'/"$LK_SMTP_HOST"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml

if [ -f /labkey/apps/SSL/keystore.tomcat ]
then
    sed -i s/'@@KEYSTORE_PASSPHRASE@@'/"$KEYSTORE_PASSPHRASE"/g /labkey/apps/tomcat/conf/server.xml
fi


# Start Tomcat Server

if ! /labkey/bin/start_tomcat.sh start

then
    echo "ERROR: TOMCAT did not start in a timely fashion"
    exit 1
fi

echo "LabKey Server application has been successfully started"

# Tomcat has started successfully. Now execute the CMD
if [ "$1" = '/labkey/bin/check_labkey.sh' ]
then
    exec "$@"
fi

exec "$@"
