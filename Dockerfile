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
ENV CC=gcc

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

ARG nasm_major=2
ARG nasm_minor=14
ARG nasm_micro=02
ARG nasm_versn=${nasm_major}.${nasm_minor}.${nasm_micro}


WORKDIR /DC

RUN mkdir nasm

WORKDIR /DC/nasm

RUN echo "Download NASM...." && \ 
wget https://www.nasm.us/pub/nasm/releasebuilds/${nasm_versn}/nasm-${nasm_versn}.tar.gz && \
tar xvfz nasm-${nasm_versn}.tar.gz

WORKDIR /DC/nasm/nasm-${nasm_versn}

RUN echo "Build and install NASM..." && \
./configure --prefix="${INSTPATH}" && \
make -j && \
make install -j

RUN echo "NASM Complete"

##########################################################
######################### YASM ###########################
##########################################################

ARG yasm_major=1
ARG yasm_minor=3
ARG yasm_micro=0
ARG yasm_versn=${yasm_major}.${yasm_minor}.${yasm_micro}

WORKDIR /DC

RUN mkdir yasm

WORKDIR /DC/yasm

RUN echo "Download YASM...." && \ 
wget http://www.tortall.net/projects/yasm/releases/yasm-${yasm_versn}.tar.gz && \
tar xvfz yasm-${yasm_versn}.tar.gz

WORKDIR /DC/yasm/yasm-${yasm_versn}

RUN echo "Build and install YASM..." && \
./configure --prefix="${INSTPATH}" && \
make -j && \
make install -j

RUN echo "YASM Complete"

##################################################################
######################### libjpegturbo ###########################
##################################################################

ARG ljpt_major=1
ARG ljpt_minor=1
ARG ljpt_micro=90
ARG ljpt_versn=${ljpt_major}.${ljpt_minor}.${ljpt_micro}

WORKDIR /DC

RUN mkdir ljpt

WORKDIR /DC/ljpt


RUN echo "Download libjpegturbo..." && \
wget "https://sourceforge.net/projects/libjpeg-turbo/files/${ljpt_versn}%20%281.2beta1%29/libjpeg-turbo-${ljpt_versn}.tar.gz" && \
tar xzvf libjpeg-turbo-${ljpt_versn}.tar.gz

WORKDIR /DC/ljpt/libjpeg-turbo-${ljpt_versn}

RUN echo "Build and install libjpegturbo...." && \
./configure --prefix="$INSTPATH" && \
make -j && \
make install -j

RUN echo "Libjpegturbo Complete"
