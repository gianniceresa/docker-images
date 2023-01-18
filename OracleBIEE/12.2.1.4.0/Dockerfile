# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2018 DATAlysis GmbH. All rights reserved.
#
# OBIEE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Business Intelligence 12.2.1.4.0 SampleAppLite
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) fmw_12.2.1.3.0_infrastructure_Disk1_1of1.zip
#     fmw_12.2.1.4.0_bi_linux64_Disk1_1of2.zip
#     fmw_12.2.1.4.0_bi_linux64_Disk1_2of2.zip
#     Download Oracle Business Intelligence 12.2.1.4.0 for Linux x64
#     from http://www.oracle.com/technetwork/middleware/bi-enterprise-edition/downloads/default-4441820.html
# (2) jdk-8u172-linux-x64.rpm
#     Download Oracle JDK 1.8.131+
#     from http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run: 
#      $ docker build -t oracle/obiee:12.2.1.4.0-sampleAppLite . 
#
# Pull base image
# ---------------
FROM oraclelinux:7-slim

# Maintainer
# ----------
MAINTAINER Gianni Ceresa <gianni.ceresa@datalysis.ch>

# Environment variables required for this build (do NOT change)
# --------------------------------------------------------------
ENV INSTALL_FILE_JDK="jdk-8u172-linux-x64.rpm"                       \
    INSTALL_FILE_WLS="fmw_12.2.1.3.0_infrastructure_Disk1_1of1.zip"  \
    INSTALL_FILE_BI_1="fmw_12.2.1.4.0_bi_linux64_Disk1_1of2.zip"     \
    INSTALL_FILE_BI_2="fmw_12.2.1.4.0_bi_linux64_Disk1_2of2.zip"     \
    OBIEE_VERSION="12.2.1.4.0"                                       \
    INSTALL_FILE_RSP_WLS="weblogic.rsp"                              \
    INSTALL_FILE_RSP_BI="obiee.rsp"                                  \
    INSTALL_FILE_RSP_CONFIG="bi_config.rsp"                          \
    RUN_FILE="runOBIEE.sh"                                           \
    ORACLE_BASE=/opt/oracle

# Use second ENV so that variable get substituted
ENV INSTALL_DIR=$ORACLE_BASE/install                                 \
    ORACLE_HOME=$ORACLE_BASE/product/$OBIEE_VERSION                  \
    DOMAIN_HOME=$ORACLE_BASE/config/domains

# Copy binaries
# -------------
COPY $INSTALL_FILE_JDK $INSTALL_FILE_WLS $INSTALL_FILE_BI_1 $INSTALL_FILE_BI_2 $INSTALL_DIR/
COPY $INSTALL_FILE_RSP_WLS $INSTALL_FILE_RSP_BI $INSTALL_FILE_RSP_CONFIG $RUN_FILE _configureOBIEE.sh _dropRCU.sh _validateRCU.sh $ORACLE_BASE/

# Setup filesystem and oracle user
# Adjust file permissions, go to /opt/oracle as user 'oracle' to proceed with Oracle Business Intelligence installation
# Install pre-req packages + Oracle JDK
# Make sure the run file is executable
# -----------------------------------------------------------------------
RUN chmod ug+x $INSTALL_DIR/$INSTALL_FILE_JDK                                   && \
    groupadd -g 500 dba                                                         && \
    groupadd -g 501 oinstall                                                    && \
    useradd -d /home/oracle -g dba -G oinstall,dba -m -s /bin/bash oracle       && \
    echo oracle:oracle | chpasswd                                               && \
    yum -y update                                                               && \
    yum -y install oracle-rdbms-server-12cR1-preinstall unzip wget tar openssl  && \
    yum -y remove java-openjdk java-openjdk-headless                            && \
    yum -y install $INSTALL_DIR/$INSTALL_FILE_JDK                               && \
    yum clean all                                                               && \
    rm $INSTALL_DIR/$INSTALL_FILE_JDK                                           && \
    touch $ORACLE_BASE/oraInst.loc                                              && \
    echo inventory_loc=$ORACLE_BASE/oraInventory >  $ORACLE_BASE/oraInst.loc    && \
    echo inst_group= >> $ORACLE_BASE/oraInst.loc                                && \
    mkdir -p $ORACLE_HOME                                                       && \
    mkdir -p $DOMAIN_HOME                                                       && \
    chown -R oracle:dba $ORACLE_BASE                                            && \
    chmod ug+x $ORACLE_BASE/*.sh


# Replace place holders (and force /dev/urandom for java)
# ---------------------
RUN sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g"   $ORACLE_BASE/$INSTALL_FILE_RSP_WLS     && \
    sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g"   $ORACLE_BASE/$INSTALL_FILE_RSP_BI      && \
    sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g"   $ORACLE_BASE/$INSTALL_FILE_RSP_CONFIG  && \
    sed -i -e "s|###DOMAIN_HOME###|$DOMAIN_HOME|g"   $ORACLE_BASE/$INSTALL_FILE_RSP_CONFIG  && \
    sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g"   $ORACLE_BASE/$RUN_FILE                 && \
    sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g"   $ORACLE_BASE/$RUN_FILE                 && \
    sed -i -e "s|source=file:/dev/random|source=file:/dev/urandom|g"     /usr/java/default/jre/lib/security/java.security  && \
    sed -i -e "s|source=file:/dev/urandom|source=file:/dev/./urandom|g"  /usr/java/default/jre/lib/security/java.security

# Start installation
# -------------------
USER oracle

RUN cd $INSTALL_DIR                       && \
    unzip $INSTALL_FILE_WLS -d ./tmp_wls  && \
    rm $INSTALL_FILE_WLS                  && \
    java -jar $(find $INSTALL_DIR/tmp_wls -name *.jar) -silent -responseFile $ORACLE_BASE/$INSTALL_FILE_RSP_WLS -invPtrLoc $ORACLE_BASE/oraInst.loc && \
    rm -rf $INSTALL_DIR/tmp_wls           && \
    unzip $INSTALL_FILE_BI_1 -d ./tmp_bi  && \
    rm $INSTALL_FILE_BI_1                 && \
    unzip $INSTALL_FILE_BI_2 -d ./tmp_bi  && \
    rm $INSTALL_FILE_BI_2                 && \
    $(find $INSTALL_DIR/tmp_bi -name *.bin) -silent -responseFile $ORACLE_BASE/$INSTALL_FILE_RSP_BI -invPtrLoc $ORACLE_BASE/oraInst.loc && \
    rm -rf $INSTALL_DIR/tmp_bi            && \
    rm -rf $INSTALL_DIR

# Set work directory & Expose ports
#--------------

WORKDIR $ORACLE_BASE

EXPOSE 9500-9514 9799

# Define default command to start Oracle Business intelligence. 
CMD $ORACLE_BASE/$RUN_FILE
