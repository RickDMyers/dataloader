# Salesforce DataLoader


## What is Dataloader?

Dataloader is a Salesforce utility for extracting and importing
data into the Salesforce platform. Please refer to the [Salesforce Dataloader](https://github.com/forcedotcom/dataloader) for further information.

## Image Summary

This docker image is based on Alpine Linux and includes the Microsoft's JDBC driver for Microsoft SQL Server database access. A multi-stage dockerfile is used to create the smallest docker image possible. 

Dataloader is executed via the bash shell, the GUI interface is not supported.


# Building the base image: dataloader/apline

Note, --build-arg is optional, see Dockerfile for the default version
in use.

```shell
git clone https:\\github\RickDMyers\dataloader
docker image build --build-arg DATALOADER_VER=43.0 -t dataloader/alpine .
docker tag dataloader/alpine dataloader/alpine:v43.0
docker image prune
```

# Scripts Included

| Command      | Description                                                   |Usage |
|--------------|---------------------------------------------------------------|----------|
| createkey.sh | Creates an encryption key file.                               |createkey.sh keyfile |
| encrypt.sh   | Uses an encryption key file to encrypt a password             |encrypt.sh password keyfile |
| decrypt.sh   | Uses an encryption key file to decrypt a password             |decrypt.sh password keyfile |
| process.sh   | Executes a dataloader process using default config directory. |process.sh processName |

# Directory Structure

| Directory | Description                             |
|-----------| ----------------------------------------|
| bin       | Place scripts and jar files here. Jars are automatically loaded using the process.sh command  |
| conf      | Default configuration (used by process.sh)  |

# How to use this image

The best use of the base image is to create your own production image containing all the code and configuration.

Start from the root directory of the application repo and create the following docker file:

## Sample Docker File

```dockerfile
FROM dataloader/alpine
LABEL maintainer="yourname@xyz.com"
LABEL description="your description"

WORKDIR /dataloader

#Copy application specific scripts
COPY ./bin/*.sh ./bin/

RUN mkdir data status log && \
    chmod +x ./bin/*.sh && \
    apk update && \
    apk add nano

COPY ./conf/* ./conf/
COPY ./key/*  ./key/
COPY ./map/*  ./map/

CMD ["sh","/dataloader/bin/dailyload.sh"]

```
## Create load scripts

Create any load scripts and place them in the bin directory.  For example,
your 'dailyload.sh' script might look like:

```shell
TimeStamp=$(date +"%F")_$(date +"%T")
DailyLogFileName="/dataloader/log/dailyload_${TimeStamp}.log"
ProcessLogFilePath="/dataloader/log"


# Execute the Datalaoder Process and log results
processWithLog()
{
    local RunProcessName=$1
    local LogFileName="${ProcessLogFilePath}/Process_${RunProcessName}_${TimeStamp}.Log"
    process.sh ${RunProcessName} > ${LogFileName}
    tail -n 1 ${LogFileName} >> ${DailyLogFileName}
}

echo
echo "************************************"
echo "**** Importing Employee records ****"
echo "****                            ****"
echo

processWithLog EmployeeImportProcess


echo
echo "***********************************************" 
echo "**** Importing Employee Email and Phone's  ****" 
echo "****                                       ****"
echo

processWithLog EmployeeEmailProcess

```

## Create production image

```shell
docker image build  -t my/dataloader .
```

## Execute production image

Create a container using the production image.

```shell

# Execute the default dailyload.sh
docker run my/dataloader 

# Or run a specific Dataloader process 
docker run my/dataloader sh /dataloader/bin/process.sh {dataloader process name}
```

## Use volume to persist logs

In the sample above, the status, data and log directories are stored inside the container and
are available until the container is removed.  A volume can be used to store the data longer 
than the lifespan of the container.

In this example a volume called "dataloader" is created and can be
referenced inside the container as /dataloader/local.


```shell
docker volume create dataloader

docker run --rm -it  --mount source=dataloader,target=/dataloader/local my/dataloader sh /dataloader/bin/dailyload.sh
```


# Encrypting database connections

Update database-conf.xml to modify the class used
to create a datasource.  

Change from:

>org.apache.commons.dbcp.BasicDataSource to 
>com.salesforce.dataloader.dao.EncryptedDataSource

Use the encrypt.sh tool to encrypt the database password.

For example:

``` shell
docker --rm -it my/dataloader sh
./bin/encrypt.sh SalesforcePassword+Token ./key/key.txt
```


