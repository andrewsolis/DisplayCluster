# Pull base image
FROM centos:centos7

LABEL Name=displaycluster Version=0.0.1

RUN echo "Update YUM..."   && \
yum -y update

RUN echo "Install EPEL..." && \
yum -y install epel-release

RUN echo "Install Development Tools..." && \
yum -y group install "Development Tools"

RUN echo "Install prerequisites..." && \
yum -y install git cmake wget


ARG INSTPATH=/opt/apps

ENV PATH="$PATH:${INSTPATH}/bin"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${INSTPATH}/lib"
ENV INCLUDE="$INCLUDE:${INSTPATH}/include"

RUN mkdir DC

WORKDIR /DC

########## OpenMPI ##########
RUN mkdir ompi

WORKDIR /DC/ompi

RUN echo "Download OPEN MPI..." && \ 
wget https://download.open-mpi.org/release/open-mpi/v1.4/openmpi-1.4.1.tar.gz && \
tar xzvf openmpi-1.4.1.tar.gz

WORKDIR /DC/ompi/openmpi-1.4.1

RUN echo "Configure and Build OpenMPI" && \
./configure --enable-mpi-threads --prefix="${INSTPATH}" && \
make -j && \
make install -j

########## BOOST ##########


# RUN apt-get -y update && apt-get install -y fortunes
# CMD ["sh", "-c", "/usr/games/fortune -a | cowsay"]