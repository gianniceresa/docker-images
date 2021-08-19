# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2020 DATAlysis LLC (https://datalysis.ch). All rights reserved.
#
# OAS DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Analytics Server 5.9.0
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) Oracle_Analytics_Server_Linux_5.9.0.zip
#     Download Oracle Analytics Server 5.9.0 Installer For Linux x86-64-bit
#     from https://www.oracle.com/solutions/business-analytics/analytics-server/analytics-server.html
# (2) fmw_12.2.1.4.0_infrastructure_Disk1_1of1.zip
#     Download Oracle WebLogic Server 12.2.1.4 - Fusion Middleware Infrastructure Installer
#     from https://www.oracle.com/middleware/technologies/weblogic-server-installers-downloads.html
# (3) jdk-8u291-linux-x64.rpm
#     Download an Oracle JDK 1.8.211+
#     from https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html
# (4) p30657796_122140_Generic.zip
#     Download Oracle WebLogic Server 12.2.1.4 Patch
#     from https://www.oracle.com/solutions/business-analytics/analytics-server/analytics-server.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run: 
#      $ docker build -t oracle/oas:5.9.0 . 


# Pull base image
# ---------------
FROM oraclelinux:7-slim

# Maintainer
# ----------
LABEL maintainer="Gianni Ceresa <gianni.ceresa@datalysis.ch>"

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV OAS_VERSION="5.9.0"                         \
    ORACLE_BASE=/opt/oracle                     \
    INSTALL_FILE_JDK="jdk-8u291-linux-x64.rpm"  \
    INSTALL_FILE_WLS="fmw_12.2.1.4.0_infrastructure_Disk1_1of1.zip" \
    INSTALL_FILE_WLS_PATCH="p30657796_122140_Generic.zip"           \
    INSTALL_FILE_OAS="Oracle_Analytics_Server_Linux_5.9.0.zip"      \
    INSTALL_RSP_WLS="weblogic.rsp"              \
    INSTALL_RSP_OAS="oas_install.rsp"           \
    CONFIG_RSP_OAS="oas_config.rsp"             \
    RUN_FILE="runOAS.sh"

# Use second ENV so that variables get substituted
ENV INSTALL_DIR=${ORACLE_BASE}/install                 \
    ORACLE_HOME=${ORACLE_BASE}/product/${OAS_VERSION}  \
    DOMAIN_HOME=${ORACLE_BASE}/config/domains

# Copy binaries
# -------------
COPY ${INSTALL_FILE_JDK} ${INSTALL_FILE_WLS} ${INSTALL_FILE_WLS_PATCH} ${INSTALL_FILE_OAS} ${INSTALL_DIR}/
COPY ${INSTALL_RSP_WLS} ${INSTALL_RSP_OAS} ${CONFIG_RSP_OAS} ${RUN_FILE} _configureOAS.sh _validateRCU.sh _dropRCU.sh ${ORACLE_BASE}/

# Setup filesystem and 'oracle' user
# Adjust file permissions, go to 'ORACLE_HOME' as 'oracle' to proceed with OAS installation
# Install pre-req packages + Oracle JDK
# Make sure the run files are executable
# ------------------------------------------
RUN useradd -d /home/oracle -m -s /bin/bash oracle                               && \
    echo oracle:oracle | chpasswd                                                && \
    yum -y update                                                                && \
    yum -y install oracle-database-preinstall-19c unzip wget tar openssl libgfortran  && \
    yum -y localinstall ${INSTALL_DIR}/${INSTALL_FILE_JDK}                       && \
    yum clean all                                                                && \
    rm ${INSTALL_DIR}/${INSTALL_FILE_JDK}                                        && \
    touch ${ORACLE_BASE}/oraInst.loc                                             && \
    echo inventory_loc=${ORACLE_BASE}/oraInventory > ${ORACLE_BASE}/oraInst.loc  && \
    echo inst_group=oracle >> ${ORACLE_BASE}/oraInst.loc                         && \
    mkdir -p ${ORACLE_HOME}                                                      && \
    mkdir -p ${DOMAIN_HOME}                                                      && \
    chown -R oracle. ${ORACLE_BASE}                                              && \
    chown -R oracle. ${ORACLE_HOME}                                              && \
    chown -R oracle. ${DOMAIN_HOME}                                              && \
    chmod ug+x ${ORACLE_BASE}/*.sh

# Replace place holders (and force /dev/urandom for Java)
# -------------------------------------------------------
RUN sed -i -e "s|###ORACLE_HOME###|${ORACLE_HOME}|g"   ${ORACLE_BASE}/${INSTALL_RSP_WLS}  && \
    sed -i -e "s|###ORACLE_HOME###|${ORACLE_HOME}|g"   ${ORACLE_BASE}/${INSTALL_RSP_OAS}  && \
    sed -i -e "s|###DOMAIN_HOME###|${DOMAIN_HOME}|g"   ${ORACLE_BASE}/${CONFIG_RSP_OAS}   && \
    sed -i -e "s|source=file:/dev/random|source=file:/dev/urandom|g"     /usr/java/default/jre/lib/security/java.security  && \
    sed -i -e "s|source=file:/dev/urandom|source=file:/dev/./urandom|g"  /usr/java/default/jre/lib/security/java.security

# Switch to 'oracle'
# ------------------
USER oracle

# Start installation
# ------------------
RUN cd ${INSTALL_DIR}                       && \
    unzip ${INSTALL_FILE_WLS} -d ./tmp_wls  && \
    rm ${INSTALL_FILE_WLS}                  && \
    java -jar $(find ${INSTALL_DIR}/tmp_wls -name *.jar) -silent -responseFile ${ORACLE_BASE}/${INSTALL_RSP_WLS} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    rm -rf ${INSTALL_DIR}/tmp_wls           && \
    unzip ${INSTALL_FILE_WLS_PATCH} -d ${INSTALL_DIR}/wls_patch  && \
    rm ${INSTALL_FILE_WLS_PATCH}            && \
    cd ${INSTALL_DIR}/wls_patch/30657796    && \
    ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    cd ${INSTALL_DIR}                       && \
    rm -rf ${INSTALL_DIR}/wls_patch         && \
    unzip ${INSTALL_FILE_OAS} -d ./tmp_oas  && \
    rm ${INSTALL_FILE_OAS}                  && \
    java -jar $(find ${INSTALL_DIR}/tmp_oas -name *.jar) -silent -responseFile ${ORACLE_BASE}/${INSTALL_RSP_OAS} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    rm -rf ${INSTALL_DIR}/tmp_oas           && \
    rm -rf ${INSTALL_DIR}

# Set work directory
# ------------------
WORKDIR ${ORACLE_BASE}

# Expose ports
# ------------
EXPOSE 9500-9514

# Define default command to start OAS
# -----------------------------------
CMD ${ORACLE_BASE}/${RUN_FILE}
