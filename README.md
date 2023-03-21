# Labkey dockerized app

This is a public repository for running LabKey Server in a docker container.
The setup also includes a possibility to connect external modules for customized webpages on the server.


## Requirements
- Docker 
- docker-compose 
- git 
- LabKey*-community.tar.gz

## Files description

- LabKeyCEServer/22.11.0/src/LabKey22.11.0-2-community.tar.gz - a LabKey Server comunity release downloaded form [official LabKey website](https://www.labkey.com/download-community-edition/current-release/) 
- enable_app.sh - utility script used for managing the application (start, stop containers)


1. Clone the repository to your local machine 
```bash
git clone ...
```

2. Download LabKey and save it to the folder `./LabKeyCEServer/22.11.0/src` 
For example: `./LabKeyCEServer/22.11.0/src/LabKey22.11.0-2-community.tar.gz`

3. Create `.env` in the current folder
```bash
POSTGRES_USER=<postgres>
POSTGRES_PASSWORD=<2134>
POSTGRES_DB=<test-lk>
PG14_LK_DATA_PATH=</home/data/pg14-lk>
LABKEY_DEFAULT_DOMAIN=<localhost.net>
```
and make adjustments according to your machine. 

4. Start LabKey app

```
docker-compose -f docker-compose.yml up -d
```







====================================
## Development branch for LabKey Server `labkey-dev-spo.leomed.ethz.ch`

Swiss Personalized Oncology Metadata Management System (LabKey) Configurations for Development instance

## Setup LabKey dockerized app



### Get the repository
    
You need to clone the repository to your local machine:

```bash
>> git clone git@gitlab.ethz.ch:spo-nds/spo-labkey-config.git
>> cd ./spo-labkey-config/
>> git checkout dev
```

### Set Parameters for LabKey  

Create an environment file for example `.env` in the above directory:

```bash
POSTGRES_USER=<postgres>
POSTGRES_PASSWORD=<2134>
POSTGRES_DB=<test-lk>
PG14_LK_DATA_PATH=</home/data/pg14-lk>
LABKEY_DEFAULT_DOMAIN=<localhost.net>
PG14_KC_DATA_PATH=</home/data/pg14-kc>
POSTGRES_KCPASSWORD=<9876>
POSTGRES_KCDB=<test-kc>
KC_ADMIN_USERNAME=<admin>
KC_ADMIN_PASSWORD=<abcd>
```

Please make adjustments according to your machine. 

### Create docker network 

The containers are running inside a dedicated network. Please see in the docker-compose.yml file

```bash
>> docker network create nexus-pht
```

### Make changes to the reverse proxy 

HTTPD service inside a docker container used as a reverse proxy to connect LabKey server. Please have a look at the httpd configuration at `$PWD/httpd_proxy/labkey_httpd.conf`. Adjust the ServerName according to the deployment site. 

### Build the container images

This deployment uses following base images:
- postgres v14
- httpd v2.4.55 
- ubuntu 22.04 LTS 

```bash 
>> docker-compose -f docker-compose.yml --env-file <labkey-var-conf> build 
```

## Run LabKey app 

For starting the LabKey application: 

```bash
>> docker-compose -f docker-compose.yml up -d
or 
>> bash enable_app.sh start  
```
By default it takes the labkey parameters from the .env file. 

For stopping the LabKey application: 

```bash
>>  docker-compose -f docker-compose.yml down
or 
>> bash enable_app.sh stop 
```
Here as well, by default it takes the labkey parameters from the .env file. 

For restarting the LabKey aplication:
```bash 
>> bash enable_app.sh restart 
```
At the moment the script expects the labkey parameters are available in the default .env file. 
