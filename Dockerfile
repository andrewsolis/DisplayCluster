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
yum -y install git cmake wget zlib-devel bzip2-devel python2-devel vim


ARG INSTPATH=/opt/apps

ENV PATH="$PATH:${INSTPATH}/bin"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${INSTPATH}/lib"
ENV INCLUDE="$INCLUDE:${INSTPATH}/include"
ENV ncores=4
ENV CFLAGS=-fPIC

RUN mkdir DC

##########################################################
######################## OpenMPI #########################
##########################################################

WORKDIR /DC

RUN mkdir ompi

WORKDIR /DC/ompi

ARG ompi_major=1
ARG ompi_minor=4
ARG ompi_micro=1
ARG ompi_versn=${ompi_major}.${ompi_minor}.${ompi_micro}

RUN echo "Download OPEN MPI..." && \ 
wget https://download.open-mpi.org/release/open-mpi/v${ompi_major}.${ompi_minor}/openmpi-${ompi_versn}.tar.gz && \
tar xzvf openmpi-${ompi_versn}.tar.gz

WORKDIR /DC/ompi/openmpi-${ompi_versn}

RUN echo "Build and Install OpenMPI" && \
./configure --enable-mpi-threads --prefix="${INSTPATH}" && \
make -j && \
make install -j

RUN echo "MPI Complete"

##########################################################
######################### Boost ##########################
##########################################################

ARG boost_major=1
ARG boost_minor=51
ARG boost_micro=0
ARG boost_versn=${boost_major}.${boost_minor}.${boost_micro}

WORKDIR /DC

RUN mkdir boost

WORKDIR /DC/boost

RUN echo "Download Boost..." && \
wget https://sourceforge.net/projects/boost/files/boost/${boost_versn}/boost_${boost_major}_${boost_minor}_${boost_micro}.tar.gz && \
tar xzvf boost_${boost_major}_${boost_minor}_${boost_micro}.tar.gz

WORKDIR /DC/boost/boost_${boost_major}_${boost_minor}_${boost_micro}

RUN echo "Build Boost..." && \
./bootstrap.sh --with-python=/usr/bin/python --with-python-version=2.7.5 --with-python-root=/usr --prefix="${INSTPATH}" --with-toolset=gcc --with-libraries=all

RUN echo "Install Boost..." && \
./b2 -j ${ncores} include="/usr/include/python2.7" --toolset=gcc --prefix="${INSTPATH}" install

RUN echo "Boost Complete"

##########################################################
######################### NASM ###########################
##########################################################

WORKDIR /DC

ENV CC=gcc

RUN mkdir nasm

WORKDIR /DC/nasm

RUN echo "Download NASM...." && \ 
wget https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.gz && \
tar xvfz nasm-2.14.02.tar.gz

# RUN apt-get -y update && apt-get install -y fortunes
# CMD ["sh", "-c", "/usr/games/fortune -a | cowsay"]