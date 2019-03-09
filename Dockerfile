# This dockerfile is used to build the base image used to run
# Salesforce Dataloder.


# docker image build -t dataloader/alpine .
# docker tag dataloader/alpine dataloader/alpine:V43.0


# docker image prune
# docker run --rm -it --name dataloader dataloader/alpine sh
# docker run --rm -it --name dataloader --mount source=dataloader,target=/dataloader/local fti/dataloader sh

# Dataloader version to pull from Salesforce github repo, see: https://github.com/forcedotcom/dataloader/releases
# Default to v43 dated June 22, 2018, use --build-arg DATALOADER_VER=43.0 when performing a docker build to override the version#
ARG DATALOADER_VER=43.0

#############################
###### Build Dataloader #####
#############################

FROM maven:latest AS build
ARG DATALOADER_VER

WORKDIR /tmp
ADD https://github.com/forcedotcom/dataloader/archive/V${DATALOADER_VER}.zip ./

RUN unzip V${DATALOADER_VER}.zip && \
    cd ./dataloader-${DATALOADER_VER} && \
    mvn clean package -DskipTests 

###############################################
###### Create Production dataloader image #####
###############################################

FROM openjdk:alpine AS production
LABEL maintainer="rick.myers@fticonsulting.com"
LABEL description="Salesforce dataloader, see https://github.com/forcedotcom/dataloader"
ARG DATALOADER_VER
WORKDIR /dataloader
ENV DATALOADER_VERSION=${DATALOADER_VER} \
    PATH=$PATH:/dataloader/bin 

COPY ./bin/*.sh ./bin/

RUN mkdir conf && \
    chmod +x ./bin/*.sh 

COPY --from=build /tmp/dataloader-${DATALOADER_VER}/target/dataloader-*-uber.jar ./bin/dataloader.jar
COPY --from=build /tmp/dataloader-${DATALOADER_VER}/license.txt ./bin
ADD https://github.com/Microsoft/mssql-jdbc/releases/download/v7.0.0/mssql-jdbc-7.0.0.jre8.jar ./bin/mssql-jdbc.jar
