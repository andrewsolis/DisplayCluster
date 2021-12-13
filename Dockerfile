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

RUN echo "############################################################" && \
echo "OPENMPI" & \
echo "############################################################"

WORKDIR /DC

RUN mkdir ompi

WORKDIR /DC/ompi

ARG ompi_major=1
ARG ompi_minor=4
ARG ompi_micro=1
ARG ompi_versn=${ompi_major}.${ompi_minor}.${ompi_micro}

RUN echo "######################" && \
echo "Download OpenMPI..." & \
echo "######################"
 
RUN wget https://download.open-mpi.org/release/open-mpi/v${ompi_major}.${ompi_minor}/openmpi-${ompi_versn}.tar.gz && \
tar xzvf openmpi-${ompi_versn}.tar.gz

WORKDIR /DC/ompi/openmpi-${ompi_versn}

RUN echo "######################" && \
echo "Build and Install OpenMPI..." & \
echo "######################"

RUN ./configure --enable-mpi-threads --prefix="${INSTPATH}" && \
make -j && \
make install -j

RUN echo "######################" && \
echo "MPI Complete" & \
echo "######################"

##########################################################
######################### Boost ##########################
##########################################################

RUN echo "############################################################" && \
echo "Boost" & \
echo "############################################################"

ARG boost_major=1
ARG boost_minor=51
ARG boost_micro=0
ARG boost_versn=${boost_major}.${boost_minor}.${boost_micro}

WORKDIR /DC

RUN mkdir boost

WORKDIR /DC/boost

RUN echo "######################" && \
echo "Download Boost..." & \
echo "######################"

RUN wget https://sourceforge.net/projects/boost/files/boost/${boost_versn}/boost_${boost_major}_${boost_minor}_${boost_micro}.tar.gz && \
tar xzvf boost_${boost_major}_${boost_minor}_${boost_micro}.tar.gz

WORKDIR /DC/boost/boost_${boost_major}_${boost_minor}_${boost_micro}

RUN echo "######################" && \
echo "Build Boost" & \
echo "######################"

RUN ./bootstrap.sh --with-python=/usr/bin/python --with-python-version=2.7.5 --with-python-root=/usr --prefix="${INSTPATH}" --with-toolset=gcc --with-libraries=all

RUN echo "######################" && \
echo "Install Boost..." & \
echo "######################"

RUN ./b2 -j ${ncores} include="/usr/include/python2.7" --toolset=gcc --prefix="${INSTPATH}" install

RUN echo "######################" && \
echo "Boost Complete" & \
echo "######################"

##########################################################
######################### NASM ###########################
##########################################################

RUN echo "############################################################" && \
echo "NASM" & \
echo "############################################################"

ARG nasm_major=2
ARG nasm_minor=14
ARG nasm_micro=02
ARG nasm_versn=${nasm_major}.${nasm_minor}.${nasm_micro}


WORKDIR /DC

RUN mkdir nasm

WORKDIR /DC/nasm

RUN echo "######################" && \
echo "Download NASM..." & \
echo "######################"

RUN wget https://www.nasm.us/pub/nasm/releasebuilds/${nasm_versn}/nasm-${nasm_versn}.tar.gz && \
tar xvfz nasm-${nasm_versn}.tar.gz

WORKDIR /DC/nasm/nasm-${nasm_versn}

RUN echo "######################" && \
echo "Build and Install NASM...." & \
echo "######################"

RUN ./configure --prefix="${INSTPATH}" && \
make -j && \
make install -j

RUN echo "######################" && \
echo "NASM Complete" & \
echo "######################"

##########################################################
######################### YASM ###########################
##########################################################

RUN echo "############################################################" && \
echo "YASM" & \
echo "############################################################"

ARG yasm_major=1
ARG yasm_minor=3
ARG yasm_micro=0
ARG yasm_versn=${yasm_major}.${yasm_minor}.${yasm_micro}

WORKDIR /DC

RUN mkdir yasm

WORKDIR /DC/yasm

RUN echo "######################" && \
echo "Download YASM...." & \
echo "######################"

RUN wget http://www.tortall.net/projects/yasm/releases/yasm-${yasm_versn}.tar.gz && \
tar xvfz yasm-${yasm_versn}.tar.gz

WORKDIR /DC/yasm/yasm-${yasm_versn}

RUN echo "######################" && \
echo "Build and Install YASM..." & \
echo "######################"

RUN ./configure --prefix="${INSTPATH}" && \
make -j && \
make install -j

RUN echo "######################" && \
echo "YASM Complete" && \
echo "######################"


##################################################################
######################### libjpegturbo ###########################
##################################################################

RUN echo "############################################################" && \
echo "Libjpegturbo" & \
echo "############################################################"

ARG ljpt_major=1
ARG ljpt_minor=1
ARG ljpt_micro=90
ARG ljpt_versn=${ljpt_major}.${ljpt_minor}.${ljpt_micro}

WORKDIR /DC

RUN mkdir ljpt

WORKDIR /DC/ljpt

RUN echo "######################" && \
echo "Download libjpegturbo..." && \
echo "######################"

RUN wget "https://sourceforge.net/projects/libjpeg-turbo/files/${ljpt_versn}%20%281.2beta1%29/libjpeg-turbo-${ljpt_versn}.tar.gz" && \
tar xzvf libjpeg-turbo-${ljpt_versn}.tar.gz

WORKDIR /DC/ljpt/libjpeg-turbo-${ljpt_versn}

RUN echo "######################" && \
echo "Build and install libjpegturbo...." && \
echo "######################"

RUN ./configure --prefix="$INSTPATH" && \
make -j && \
make install -j

RUN echo "######################" && \
echo "Libjpegturbo Complete" && \
echo "######################"

############################################################
######################### ffmpeg ###########################
############################################################

RUN echo "############################################################" && \
echo "FFMPEG" & \
echo "############################################################"

ARG lame_major=3
ARG lame_minor=99
ARG lame_micro=5
ARG lame_versn=${lame_major}.${lame_minor}.${lame_micro}

ARG opus_major=1
ARG opus_minor=0
ARG opus_micro=2
ARG opus_versn=${opus_major}.${opus_minor}.${opus_micro}

ARG ogg_major=1
ARG ogg_minor=1
ARG ogg_micro=4
ARG ogg_versn=${ogg_major}.${ogg_minor}.${ogg_micro}

ARG theora_major=1
ARG theora_minor=1
ARG theora_micro=1
ARG theora_versn=${theora_major}.${theora_minor}.${theora_micro}

ARG vorbis_major=1
ARG vorbis_minor=3
ARG vorbis_micro=3
ARG vorbis_versn=${vorbis_major}.${vorbis_minor}.${vorbis_micro}

ARG vpx_major=1
ARG vpx_minor=2
ARG vpx_micro=0
ARG vpx_versn=${vpx_major}.${vpx_minor}.${vpx_micro}

ARG ffmpeg_major=0
ARG ffmpeg_minor=9
ARG ffmpeg_micro=1
ARG ffmpeg_versn=${ffmpeg_major}.${ffmpeg_minor}.${ffmpeg_micro}

WORKDIR /DC

RUN mkdir ffmpeg

WORKDIR /DC/ffmpeg

RUN echo "######################" && \
echo "x264...." & \
echo "######################"

RUN wget https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20170101-2245-stable.tar.bz2 && \
tar xvfj x264-snapshot-20170101-2245-stable.tar.bz2

WORKDIR /DC/ffmpeg/x264-snapshot-20170101-2245-stable

RUN ./configure --prefix="$INSTPATH" --enable-shared && \
make -j ${ncores} && \
make install -j ${ncores}

WORKDIR /DC/ffmpeg
RUN echo "######################" && \
echo "mp3lame...." & \
echo "######################"

RUN curl -O -L https://downloads.sourceforge.net/project/lame/lame/${lame_major}.${lame_minor}/lame-${lame_versn}.tar.gz && \
tar xzvf lame-${lame_versn}.tar.gz

WORKDIR /DC/ffmpeg/lame-${lame_versn} 

RUN ./configure --prefix="$INSTPATH" --disable-static --enable-nasm && \
make -j ${ncores} && \
make install -j ${ncores}

WORKDIR /DC/ffmpeg
RUN echo "######################" && \
echo "ogg...." & \
echo "######################"

RUN wget http://downloads.xiph.org/releases/ogg/libogg-${ogg_versn}.tar.gz && \
tar xzvf libogg-${ogg_versn}.tar.gz

WORKDIR /DC/ffmpeg/libogg-${ogg_versn}

RUN ./configure --prefix="$INSTPATH" --disable-static && \
make -j ${ncores} && \
make install -j ${ncores}

WORKDIR /DC/ffmpeg
RUN echo "######################" && \
echo "theora...." & \
echo "######################"

RUN wget http://downloads.xiph.org/releases/theora/libtheora-${theora_version}.tar.gz && \
tar xzvf libtheora-${theora_version}.tar.gz

WORKDIR /DC/ffmpeg/libtheora-${theora_version}

RUN ./configure --prefix="$INSTPATH" --disable-static --with-ogg="$INSTPATH" \
make -j ${ncores} && \
make install -j ${ncores}