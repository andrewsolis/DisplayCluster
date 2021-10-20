# Pull base image
FROM centos:centos7

LABEL Name=displaycluster Version=0.0.1

RUN echo "Update YUM..."   && \
yum -y update

RUN echo "Install EPEL..." && \
yum -y install epel-release

RUN echo "Install prerequisites..." && \
yum -y install git cmake 

RUN mkdir DC

WORKDIR /DC

# Build OpenMPI

# RUN apt-get -y update && apt-get install -y fortunes
# CMD ["sh", "-c", "/usr/games/fortune -a | cowsay"]