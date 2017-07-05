# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2017 DATAlysis GmbH. All rights reserved.
#
# OBI-BVT DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle BI Baseline Validation Tool
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) OracleBI-BVT.zip
#     Download Oracle BI Baseline Validation Tool
#     http://www.oracle.com/technetwork/middleware/bi/downloads/bi-bvt-download-3587672.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run: 
#      $ docker build -t oracle/obi-bvt . 
#
# Pull base image
# ---------------
FROM oraclelinux:7-slim

# Maintainer
# ----------
MAINTAINER Gianni Ceresa <gianni.ceresa@datalysis.ch>

# Environment variables required for this build (do NOT change)
# --------------------------------------------------------------
ENV INSTALL_FILE_OBIBVT="OracleBI-BVT.zip"                       \
    INSTALL_DIR=/opt/

# Copy binaries
# -------------
COPY $INSTALL_FILE_OBIBVT $INSTALL_DIR/

# Install pre-req packages + JDK
# Install packages for the UI tests using Firefox
# (newer versions of Firefox don't work)
# Fix a missing library because too old
# Unzip Orable BI BVT
# -----------------------------------------------------------------------
RUN yum -y update                                                     && \
    yum -y install unzip which java-1.8.0-openjdk                     && \
    yum-config-manager --enable ol7_optional_latest                   && \
    yum -y install xorg-x11-server-Xvfb                               && \
    yum -y install libpng12 libXtst gstreamer gstreamer-plugins-base  && \
    yum -y install firefox-38.7.0-1.0.1.el7_2                         && \
    ln -s /usr/lib64/libtiff.so.5 /usr/lib64/libtiff.so.3             && \
    yum clean all                                                     && \
    cd $INSTALL_DIR                                                   && \
    unzip $INSTALL_FILE_OBIBVT -d BVT/                                && \
    rm $INSTALL_FILE_OBIBVT

# Work folder
#--------------

WORKDIR $INSTALL_DIR/BVT/

# Define default command: bash 
#CMD xvfb-run ./bin/obibvt -config /opt/BVT/testconfig.xml -deployment PreUpgrade
CMD /bin/bash
