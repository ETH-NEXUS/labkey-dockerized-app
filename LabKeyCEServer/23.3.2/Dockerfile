FROM ubuntu:22.04

ENV LABKEY_VERSION=24.3.4-6 \
     LABKEY_DIST=24.3.4-6-community \
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
     ls -lah && \
     tar -xzf /labkey/src/LabKey$LABKEY_DIST.tar.gz && \
     ls -lah LabKey$LABKEY_DIST && \
     cp -R LabKey$LABKEY_DIST/* /labkey/server && \
     mkdir -p /labkey/server/files && \
     mkdir -p /labkey/server/modules/nexus_external_modules && \
     chown -R tomcat:tomcat /labkey/server && \
     rm -rf LabKey$LABKEY_DIST && \
     rm LabKey$LABKEY_DIST.tar.gz

## expose LabKey server web application
EXPOSE 8080

VOLUME  ["/labkey/server/files", "/labkey/apps/tomcat/logs"]

WORKDIR /labkey/

## health check for the container
HEALTHCHECK --interval=60s --timeout=10s --retries=5 \
    CMD curl -fsS http://localhost:8080/ > /dev/null || exit 1

ENTRYPOINT ["/labkey/bin/start_labkey.sh"]
CMD ["/labkey/bin/check_labkey.sh"]
