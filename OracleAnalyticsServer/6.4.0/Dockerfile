# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2022 DATAlysis LLC (https://datalysis.ch). All rights reserved.
#
# OAS DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Analytics Server 6.4.0 (2022)
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) jdk-8u321-linux-x64.rpm
#     Download Oracle JSK 1.8.211+ (1.8.321 is used in this image)
#     from https://www.oracle.com/java/technologies/downloads/#java8
# (2) fmw_12.2.1.4.0_infrastructure_Disk1_1of1.zip
#     Download Oracle WebLogic Server 12.2.1.4 - Fusion Middleware Infrastructure Installer
#     from https://www.oracle.com/middleware/technologies/weblogic-server-installers-downloads.html
# (3) Oracle_Analytics_Server_Linux_6.4.0.zip
#     Download Oracle Analytics Server 2022 (6.4) Installer For Linux x86-64-bit
#     from https://www.oracle.com/solutions/business-analytics/analytics-server/analytics-server.html
# (4) p28186730_139428_Generic.zip
#     Download OPatch 13.9.4.2.8+
#     from https://support.oracle.com/epmos/faces/PatchDetail?patchId=28186730
# (5) p33618954_122140_Generic.zip
#     Download OWSM Bundle Patch
#     from https://support.oracle.com/epmos/faces/PatchDetail?patchId=33618954
# (6) p33751264_122140_Generic.zip
#     Download WLS Stack Patch Bundle
#     from https://support.oracle.com/epmos/faces/PatchDetail?patchId=33751264
# (7) p33735326_12214220105_Generic.zip
#     Download Log4j 2.17.1 Overlay for WLS PSU
#     from https://support.oracle.com/epmos/faces/PatchDetail?patchId=33735326
# (8) p33791665_12214220105_Generic.zip
#     Download Log4j v1 Overlay for WLS PSU
#     from https://support.oracle.com/epmos/faces/PatchDetail?patchId=33791665
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run: 
#      $ docker build -t oracle/oas:6.4.0 .

# Pull base image
# ---------------
FROM oraclelinux:8

# Maintainer
# ----------
LABEL maintainer="Gianni Ceresa <gianni.ceresa@datalysis.ch>"

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV OAS_VERSION="6.4.0"                         \
    ORACLE_BASE=/opt/oracle                     \
    INSTALL_FILE_JDK="jdk-8u321-linux-x64.rpm"  \
    INSTALL_FILE_WLS="fmw_12.2.1.4.0_infrastructure_Disk1_1of1.zip" \
    INSTALL_FILE_OAS="Oracle_Analytics_Server_Linux_6.4.0.zip"      \
    INSTALL_FILE_OPATCH="p28186730_139428_Generic.zip"              \
    INSTALL_FILE_OWSM_PATCH="p33618954_122140_Generic.zip"          \
    INSTALL_FILE_WLS_PATCH_BUNDLE="p33751264_122140_Generic.zip"         \
    INSTALL_FILE_WLS_PATCH_LOG4J2="p33735326_12214220105_Generic.zip"    \
    INSTALL_FILE_WLS_PATCH_LOG4J1="p33791665_12214220105_Generic.zip"    \
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
COPY ${INSTALL_FILE_JDK} ${INSTALL_FILE_WLS} ${INSTALL_FILE_OAS} ${INSTALL_FILE_OPATCH} ${INSTALL_FILE_OWSM_PATCH} ${INSTALL_FILE_WLS_PATCH_BUNDLE} ${INSTALL_FILE_WLS_PATCH_LOG4J2} ${INSTALL_FILE_WLS_PATCH_LOG4J1} ${INSTALL_DIR}/
COPY ${INSTALL_RSP_WLS} ${INSTALL_RSP_OAS} ${CONFIG_RSP_OAS} ${RUN_FILE} _configureOAS.sh _validateRCU.sh _dropRCU.sh ${ORACLE_BASE}/

# Setup filesystem and 'oracle' user
# Adjust file permissions, go to 'ORACLE_HOME' as 'oracle' to proceed with OAS installation
# Install pre-req packages + Oracle JDK
# Make sure the run files are executable
# ------------------------------------------
RUN useradd -d /home/oracle -m -s /bin/bash oracle                               && \
    echo oracle:oracle | chpasswd                                                && \
    dnf -y update                                                                && \
    dnf -y install binutils gcc gcc-c++ glibc glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel libnsl sysstat motif motif-devel redhat-lsb redhat-lsb-core openssl make xorg-x11-utils compat-libgfortran-48  && \
    dnf -y install ${INSTALL_DIR}/${INSTALL_FILE_JDK}                            && \
    dnf clean all                                                                && \
    rm ${INSTALL_DIR}/${INSTALL_FILE_JDK}                                        && \
    mkdir -p ${ORACLE_BASE}                                                      && \
    mkdir -p ${ORACLE_HOME}                                                      && \
    mkdir -p ${DOMAIN_HOME}                                                      && \
    touch ${ORACLE_BASE}/oraInst.loc                                             && \
    echo inventory_loc=${ORACLE_BASE}/oraInventory > ${ORACLE_BASE}/oraInst.loc  && \
    echo inst_group=oracle >> ${ORACLE_BASE}/oraInst.loc                         && \
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
RUN cd ${INSTALL_DIR}  && \
    unzip ${INSTALL_DIR}/${INSTALL_FILE_WLS} -d ${INSTALL_DIR}/tmp_wls                                                                                  && \
    rm ${INSTALL_DIR}/${INSTALL_FILE_WLS}                                                                                                               && \
    java -jar $(find ${INSTALL_DIR}/tmp_wls -name *.jar) -silent -responseFile ${ORACLE_BASE}/${INSTALL_RSP_WLS} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    rm -rf ${INSTALL_DIR}/tmp_wls                                                                                                                       && \
    unzip ${INSTALL_DIR}/${INSTALL_FILE_OAS} -d ${INSTALL_DIR}/tmp_oas                                                                                  && \
    rm ${INSTALL_DIR}/${INSTALL_FILE_OAS}                                                                                                               && \
    java -jar $(find ${INSTALL_DIR}/tmp_oas -name *.jar) -silent -responseFile ${ORACLE_BASE}/${INSTALL_RSP_OAS} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    rm -rf ${INSTALL_DIR}/tmp_oas                                                                                                                       && \
    unzip ${INSTALL_DIR}/${INSTALL_FILE_OPATCH} -d ${INSTALL_DIR}/tmp_opatch                                                                 && \
    rm ${INSTALL_DIR}/${INSTALL_FILE_OPATCH}                                                                                                 && \
    java -jar ${INSTALL_DIR}/tmp_opatch/6880880/opatch_generic.jar -silent oracle_home=${ORACLE_HOME} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    rm -rf ${INSTALL_DIR}/${INSTALL_DIR}/tmp_opatch                                                                                          && \
    unzip ${INSTALL_DIR}/${INSTALL_FILE_OWSM_PATCH} -d ${INSTALL_DIR}/owsm_patch      && \
    rm ${INSTALL_FILE_OWSM_PATCH}                                                     && \
    cd ${INSTALL_DIR}/owsm_patch/33618954                                             && \
    ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    cd ${INSTALL_DIR}                                                                 && \
    rm -rf ${INSTALL_DIR}/owsm_patch                                                  && \
    unzip ${INSTALL_DIR}/${INSTALL_FILE_WLS_PATCH_BUNDLE} -d ${INSTALL_DIR}/wsl_patch_bundle          && \
    rm ${INSTALL_DIR}/${INSTALL_FILE_WLS_PATCH_BUNDLE}                                                && \
    cd ${INSTALL_DIR}/wsl_patch_bundle/WLS_SPB_12.2.1.4.220112/binary_patches                         && \
    ${ORACLE_HOME}/OPatch/opatch napply -silent -oh ${ORACLE_HOME} -phBaseFile linux64_patchlist.txt  && \
    cd ${INSTALL_DIR}                                                                                 && \
    rm -rf ${INSTALL_DIR}/wsl_patch_bundle                                                            && \
    unzip ${INSTALL_DIR}/${INSTALL_FILE_WLS_PATCH_LOG4J2} -d ${INSTALL_DIR}/wsl_patch_log4j2  && \
    rm ${INSTALL_DIR}/${INSTALL_FILE_WLS_PATCH_LOG4J2}                                        && \
    cd ${INSTALL_DIR}/wsl_patch_log4j2/33735326                                               && \
    ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc          && \
    cd ${INSTALL_DIR}                                                                         && \
    rm -rf ${INSTALL_DIR}/wsl_patch_log4j2                                                    && \
    unzip ${INSTALL_DIR}/${INSTALL_FILE_WLS_PATCH_LOG4J1} -d ${INSTALL_DIR}/wsl_patch_log4j1  && \
    rm ${INSTALL_DIR}/${INSTALL_FILE_WLS_PATCH_LOG4J1}                                        && \
    cd ${INSTALL_DIR}/wsl_patch_log4j1/33791665                                               && \
    ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc          && \
    cd ${INSTALL_DIR}                                                                         && \
    rm -rf ${INSTALL_DIR}/wsl_patch_log4j1                                                    && \
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
