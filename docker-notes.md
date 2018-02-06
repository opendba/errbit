# Small How-To

* Make sure you have latest version of docker
* Install Docker local-persist volume plugin: https://github.com/CWSpear/local-persist
* Install docker-compose
* Check docker-compose.yaml and adjust host name and volume path for volume `mongo_db`
* When running first time in docker, make sure you have run to initialize database, this will also give you admin account details:
```bash
docker-compose run errbit /bin/sh
rake errbit:bootstrap
```
* To start everything up use from errbit directory:
```bash
docker-compose up -d
```
