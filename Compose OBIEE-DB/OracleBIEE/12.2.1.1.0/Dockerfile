# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2016 DATAlysis GmbH. All rights reserved.
#
# OBIEE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Business Intelligence 12.2.1.1.0 SampleAppLite
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) fmw_12.2.1.1.0_infrastructure_Disk1_1of1.zip
#     fmw_12.2.1.1.0_bi_linux64_Disk1_1of2.zip
#     fmw_12.2.1.1.0_bi_linux64_Disk1_2of2.zip
#     Download Oracle Business Intelligence 12.2.1.1.0 for Linux x64
#     from http://www.oracle.com/technetwork/middleware/bi-enterprise-edition/downloads/business-intelligence-3046226.html
# (2) jdk-8u101-linux-x64.rpm
#     Download Oracle JDK 1.8.77+
#     from http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# To be used by Docker Compose (linked with database container)
#
# Pull base image
# ---------------
FROM oraclelinux:latest

# Maintainer
# ----------
MAINTAINER Gianni Ceresa <gianni.ceresa@datalysis.ch>

# Environment variables required for this build (change defaults if needed)
#--------------------------------------------------------------------------
ENV INSTALL_FILE_JDK="jdk-8u101-linux-x64.rpm"                       \
    INSTALL_FILE_WLS="fmw_12.2.1.1.0_infrastructure_Disk1_1of1.zip"  \
    INSTALL_FILE_BI_1="fmw_12.2.1.1.0_bi_linux64_Disk1_1of2.zip"     \
    INSTALL_FILE_BI_2="fmw_12.2.1.1.0_bi_linux64_Disk1_2of2.zip"     \
    INSTALL_FILE_RSP_WLS="weblogic.rsp"                              \
    INSTALL_FILE_RSP_BI="obiee.rsp"                                  \
    INSTALL_FILE_RSP_CONFIG="bi_config.rsp"                          \
    CHKSUM_TEST="checksumPackages.sh"                                \
    CHKSUM_MD5="Checksum.md5"                                        \
    WAIT_DB_CLASS="OracleJDBC.class"                                 \
    WAIT_DB_SCRIPT="wait-for-database.sh"                            \
    RUN_FILE="runOBIEE.sh"                                           \
    ORACLE_BASE=/opt/oracle                                          \
    ORACLE_HOME=/opt/oracle/biee

# Use second ENV so that variable get substituted
ENV INSTALL_DIR=$ORACLE_BASE/install

# Copy binaries
# -------------
COPY $INSTALL_FILE_JDK $INSTALL_FILE_WLS $INSTALL_FILE_BI_1 $INSTALL_FILE_BI_2 $CHKSUM_TEST $CHKSUM_MD5 $INSTALL_DIR/
COPY $INSTALL_FILE_RSP_WLS $INSTALL_FILE_RSP_BI $INSTALL_FILE_RSP_CONFIG $RUN_FILE $WAIT_DB_CLASS $WAIT_DB_SCRIPT $ORACLE_BASE/

# Check MD5 checksum of binaries and abort if mismatch
#------------------------------------------------------
RUN cd $INSTALL_DIR          && \
    chmod ug+x $CHKSUM_TEST  && \
    ./$CHKSUM_TEST

# Setup filesystem and oracle user
# Adjust file permissions, go to /opt/oracle as user 'oracle' to proceed with Oracle Business Intelligence installation
# Install pre-req packages + Oracle JDK + get rid of previous JDK if any
# Make sure run files are executables
# -----------------------------------------------------------------------
RUN chmod ug+x $INSTALL_DIR/$INSTALL_FILE_JDK                                   && \
    groupadd -g 500 dba                                                         && \
    groupadd -g 501 oinstall                                                    && \
    useradd -d /home/oracle -g dba -G oinstall,dba -m -s /bin/bash oracle       && \
    echo oracle:oracle | chpasswd                                               && \
    yum -y install oracle-rdbms-server-12cR1-preinstall unzip wget tar openssl  && \
    yum -y remove java-openjdk java-openjdk-headless                            && \
    yum -y install $INSTALL_DIR/$INSTALL_FILE_JDK                               && \
    yum clean all                                                               && \
    rm $INSTALL_DIR/$INSTALL_FILE_JDK                                           && \
    touch $ORACLE_BASE/oraInst.loc                                              && \
    echo inventory_loc=$ORACLE_BASE/oraInventory >  $ORACLE_BASE/oraInst.loc    && \
    echo inst_group= >> $ORACLE_BASE/oraInst.loc                                && \
    chown -R oracle:dba $ORACLE_BASE                                            && \
    chmod ug+x $ORACLE_BASE/$RUN_FILE                                           && \
    chmod ug+x $ORACLE_BASE/$WAIT_DB_SCRIPT


# Replace place holders
# ---------------------
RUN sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" $ORACLE_BASE/$INSTALL_FILE_RSP_WLS    && \
    sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" $ORACLE_BASE/$INSTALL_FILE_RSP_BI     && \
    sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" $ORACLE_BASE/$INSTALL_FILE_RSP_CONFIG && \
    sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" $ORACLE_BASE/$RUN_FILE                && \
    sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" $ORACLE_BASE/$RUN_FILE

# Start installation
# -------------------
USER oracle

RUN cd $INSTALL_DIR                       && \
    unzip $INSTALL_FILE_WLS -d ./tmp_wls  && \
    rm $INSTALL_FILE_WLS                  && \
    java -jar $INSTALL_DIR/tmp_wls/fmw_12.2.1.1.0_infrastructure.jar -silent -responseFile $ORACLE_BASE/$INSTALL_FILE_RSP_WLS -invPtrLoc $ORACLE_BASE/oraInst.loc && \
    rm -rf $INSTALL_DIR/tmp_wls           && \
    unzip $INSTALL_FILE_BI_1 -d ./tmp_bi  && \
    rm $INSTALL_FILE_BI_1                 && \
    unzip $INSTALL_FILE_BI_2 -d ./tmp_bi  && \
    rm $INSTALL_FILE_BI_2                 && \
    ./tmp_bi/bi_platform-12.2.1.1.0_linux64.bin  -silent -responseFile $ORACLE_BASE/$INSTALL_FILE_RSP_BI -invPtrLoc $ORACLE_BASE/oraInst.loc && \
    rm -rf $INSTALL_DIR/tmp_bi           && \
    rm -rf $INSTALL_DIR

# Expose ports
#--------------

WORKDIR $ORACLE_HOME

EXPOSE 9500-9514 9799
    
# Define default command to start Oracle Business intelligence. 
CMD $ORACLE_BASE/$RUN_FILE
