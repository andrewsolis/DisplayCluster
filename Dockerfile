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
ENV ncores=8

RUN mkdir DC

#############################
########## OpenMPI ##########
#############################

WORKDIR /DC

RUN mkdir ompi

WORKDIR /DC/ompi

RUN echo "Download OPEN MPI..." && \ 
wget https://download.open-mpi.org/release/open-mpi/v1.4/openmpi-1.4.1.tar.gz && \
tar xzvf openmpi-1.4.1.tar.gz

WORKDIR /DC/ompi/openmpi-1.4.1

RUN echo "Build and Install OpenMPI" && \
./configure --enable-mpi-threads --prefix="${INSTPATH}" && \
make -j && \
make install -j

RUN echo "MPI Complete"

###########################
########## BOOST ##########
###########################

WORKDIR /DC

ENV CC=mpicxx
ENV CXX=mpicxx
ENV CFLAGS=-fPIC

RUN mkdir boost

WORKDIR /DC/boost

RUN echo "Download Boost..." && \
wget https://sourceforge.net/projects/boost/files/boost/1.51.0/boost_1_51_0.tar.gz && \
tar xzvf boost_1_51_0.tar.gz

WORKDIR /DC/boost/boost_1_51_0

RUN echo "Build Boost..." && \
./bootstrap.sh --with-python=/usr/bin/python --with-python-version=2.7.5 --with-python-root=/usr --prefix="${INSTPATH}" --with-toolset=gcc --with-libraries=all

RUN echo "Install Boost..." && \
./b2 include="/usr/include/python2.7" --toolset=gcc --prefix="${INSTPATH}" install

RUN echo "Boost Complete"


# RUN apt-get -y update && apt-get install -y fortunes
# CMD ["sh", "-c", "/usr/games/fortune -a | cowsay"]