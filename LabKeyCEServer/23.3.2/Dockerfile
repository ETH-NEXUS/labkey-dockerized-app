#
# Dockerfile for running LabKey Server in a single container
#
# Software
# ============
# Software versions are specified as ENV variables. This allows
# for a different version to be specified at build time for the image.
#
#   * Base: Ubuntu 22.04 LTS
#   * Tomcat: 9.0.71
#   * Java: 1.8u112 (from the debian pkg openjdk-17-jdk LTS)
#   * LabKey Server: 23.3.2-5-community
#
# Storage:
# =============
# The following directories will be mounted at Data Volumes
#   * Tomcat logs Directory
#   * LabKey Server Sitewide FileRoot Directory
#
# This allows for each backup and review of log files.
#
# Secrets
# ============
# The ENTRYPOINT script (/labkey/bin/start_labkey.sh) reads
#   * Master Encryption Key from LABKEY_ENCRYPTION_KEY ENV variable
#
# You can specify values for these variables in the Dockerfile, as an ENV variable
# during the build time or run time. We recommend specifying them as part of the run
# command.

FROM ubuntu:22.04

ENV LABKEY_VERSION=23.3.2 \
     LABKEY_DIST=23.3.2-5-community \
     TOMCAT_VERSION=9.0.71 \
     LABKEY_ENCRYPTION_KEY=sh8ZLBcpKAD82MtjDwhuq2BoF3m5qkctawNuWcq2qQwsRU6Vgi7O1j981JYQhRb \
     PG_HOST=db

ARG POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB SMTP_HOST
ENV PG_USER=$POSTGRES_USER \
     PG_PASSWORD=$POSTGRES_PASSWORD \
     PG_DATABASE=$POSTGRES_DB \
     LK_SMTP_HOST=$SMTP_HOST

RUN apt-get update && \
     apt-get upgrade --yes && \
     export DEBIAN_FRONTEND=noninteractive && \
     apt-get -y -q install openjdk-17-jdk && \
     apt-get -y -q install build-essential ssl-cert libreadline-dev zlib1g-dev gnupg wget curl graphviz && \
     mkdir -p /labkey/src/labkey && \
     mkdir -p /labkey/apps/tomcat && \
     mkdir -p /labkey/bin && \
     apt-get -y -q purge build-essential && \
     apt-get -y -q autoremove && \
     apt-get clean -y

## create tomcat user account
RUN useradd -m -u 3000 tomcat

## download, install tomcat and configure
RUN cd /labkey/src && \
    wget --no-verbose https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
     tar -xzf apache-tomcat-$TOMCAT_VERSION.tar.gz && \
     mv apache-tomcat-$TOMCAT_VERSION/* /labkey/apps/tomcat && \
     mkdir -p /labkey/apps/tomcat/conf/Catalina/localhost && \
     mkdir -p /labkey/apps/tomcat/temp && \
     mkdir -p /labkey/apps/tomcat/lib && \
     rm -fr /labkey/apps/tomcat/webapps/examples && \
     rm -fr /labkey/apps/tomcat/webapps/ROOT && \
     rm -fr /labkey/apps/tomcat/webapps/manager && \
     rm -fr /labkey/apps/tomcat/webapps/docs && \
     rm -fr /labkey/apps/tomcat/webapps/host-manager && \
     chown -R tomcat:tomcat /labkey/apps/tomcat && \
     rm /labkey/src/apache-tomcat-$TOMCAT_VERSION.tar.gz

ADD ./tomcat/server.xml /labkey/apps/tomcat/conf/server.xml
ADD ./labkey/labkey.xml /labkey/apps/tomcat/conf/Catalina/localhost/ROOT.xml
ADD ["./labkey/start_labkey.sh","./tomcat/start_tomcat.sh","./labkey/check_labkey.sh", "/labkey/bin/"]

## install and configure LabKey server
COPY ./src/LabKey$LABKEY_DIST.tar.gz /labkey/src/

RUN chmod +x /labkey/bin/* && \
     mkdir -p /labkey/server && \
     cd /labkey/src && \
     ls && \
     tar -xzf /labkey/src/LabKey$LABKEY_DIST.tar.gz && \
     cp -R LabKey$LABKEY_DIST/modules /labkey/server && \
     cp -R LabKey$LABKEY_DIST/labkeywebapp /labkey/server && \
     cp -R LabKey$LABKEY_DIST/pipeline-lib /labkey/server && \
     cp -f LabKey$LABKEY_DIST/tomcat-lib/*.jar /labkey/apps/tomcat/lib/ && \
     mkdir /labkey/server/files && \
     mkdir /labkey/server/modules/nexus_external_modules && \
     chown -R tomcat:tomcat /labkey/server && \
     rm -rf LabKey$LABKEY_DIST && \
     rm LabKey$LABKEY_DIST.tar.gz

## expose LabKey server web application
EXPOSE 8080

VOLUME  ["/labkey/server/files", "/labkey/apps/tomcat/logs"]
# TODO
# VOLUME "${LABKEY_FILES_ROOT}/@files"
# VOLUME "${LABKEY_HOME}/logs"

WORKDIR /labkey/

## health check for the container
HEALTHCHECK --interval=60s --timeout=10s --retries=5 \
    CMD curl -fsS http://localhost:8080/ > /dev/null || exit 1

ENTRYPOINT ["/labkey/bin/start_labkey.sh"]
CMD ["/labkey/bin/check_labkey.sh"]






























#
# Dockerfile for running LabKey Server in a single container
#
# Software
# ============
# Software versions are specified as ENV variables. This allows
# for a different version to be specified at build time for the image.
#
#   * Base: Ubuntu Core 20.04
#   * Tomcat: 9.0.55
#   * Java: 1.8u112 (from the debian pkg openjdk-17-jdk)
#   * LabKey Server: 21.11.4-community
#
#
# Storage:
# =============
# The following directories will be mounted at Data Volumes
#   * Tomcat logs Directory
#   * LabKey Server Sitewide FileRoot Directory
#
# This allows for each backup and review of log files.
#
# Secrets
# ============
# IMPORTANT: This Dockerfile will read the required secrets (ie passwords, etc)
# from ENV variables. There are other methods for managing secrets; feel free to
# modify this Dockerfile or ENTRYPOINT script (start_labkey.sh) to use a
# different method.
#
# The ENTRYPOINT script (/labkey/bin/start_labkey.sh) reads
#   * Master Encryption Key from LABKEY_ENCRYPTION_KEY ENV variable
#
# You can specify values for these variables in the Dockerfile, as an ENV variable
# during the build time or run time. We recommend specifying them as part of the run
# command.

# FROM ubuntu:20.04

# ENV LABKEY_VERSION=21.11.4 \
#      LABKEY_DIST=21.11.4-5-community \
#      TOMCAT_VERSION=9.0.55 \
#      LABKEY_ENCRYPTION_KEY=sh8ZLBcpKAD82MtjDwhuq2BoF3m5qkctawNuWcq2qQwsRU6Vgi7O1j981JYQhRb \
#      PG_HOST=db \
#      PG_USER=postgres \
#      PG_PASSWORD=wracmal9

# RUN apt-get update && \
#      export DEBIAN_FRONTEND=noninteractive && \
#      apt-get -y -q install build-essential ssl-cert libreadline-dev zlib1g-dev gnupg wget curl openjdk-17-jdk && \
#      mkdir -p /labkey/src/labkey && \
#      mkdir -p /labkey/apps/tomcat && \
#      mkdir -p /labkey/bin && \
#      apt-get -y -q purge build-essential && \
#      apt-get -y -q autoremove && \
#      apt-get clean -y

# ## create tomcat user account
# RUN useradd -m -u 3000 tomcat

# RUN echo $PG_DATA_PATH

# ## install tomcat and configure
# RUN cd /labkey/src && \
#      wget --no-verbose https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
#      tar -xzf apache-tomcat-$TOMCAT_VERSION.tar.gz && \
#      mv apache-tomcat-$TOMCAT_VERSION/* /labkey/apps/tomcat && \
#      mkdir -p /labkey/apps/tomcat/conf/Catalina/localhost && \
#      mkdir -p /labkey/apps/tomcat/temp && \
#      mkdir -p /labkey/apps/tomcat/lib && \
#      chown -R tomcat.tomcat /labkey/apps/tomcat && \
#      rm /labkey/src/apache-tomcat-$TOMCAT_VERSION.tar.gz

# ADD ./tomcat/server.xml /labkey/apps/tomcat/conf/server.xml
# ADD ./labkey/labkey.xml /labkey/apps/tomcat/conf/Catalina/localhost/ROOT.xml
# ADD ["./labkey/start_labkey.sh","./tomcat/start_tomcat.sh","./labkey/check_labkey.sh", "/labkey/bin/"]

# ## install and configure LabKey server
# COPY ./src/LabKey$LABKEY_DIST-bin.tar.gz /labkey/src/

# RUN chmod +x /labkey/bin/* && \
#      mkdir -p /labkey/labkey && \
#      cd /labkey/src && \
#      ls && \
#      tar -xzf /labkey/src/LabKey$LABKEY_DIST-bin.tar.gz && \
#      cp -R LabKey$LABKEY_DIST/modules /labkey/labkey && \
#      cp -R LabKey$LABKEY_DIST/labkeywebapp /labkey/labkey && \
#      cp -R LabKey$LABKEY_DIST/pipeline-lib /labkey/labkey && \
#      cp -f LabKey$LABKEY_DIST/tomcat-lib/*.jar /labkey/apps/tomcat/lib/ && \
#      mkdir /labkey/labkey/files && \
#      mkdir /labkey/labkey/modules/nexus_external_modules && \
#      chown -R tomcat.tomcat /labkey/labkey && \
#      rm -rf LabKey$LABKEY_DIST && \
#      rm LabKey$LABKEY_DIST-bin.tar.gz
      
# ## expose LabKey server web application
# EXPOSE 8080

# VOLUME  ["/labkey/labkey/files", "/labkey/apps/tomcat/logs"]

# WORKDIR /labkey/

# ## health check for the container
# HEALTHCHECK --interval=60s --timeout=10s --retries=5 \
#     CMD curl -fsS http://localhost:8080/ > /dev/null || exit 1


# ENTRYPOINT ["/labkey/bin/start_labkey.sh"]
# CMD ["/labkey/bin/check_labkey.sh"]
