# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2024 DATAlysis LLC (https://datalysis.ch). All rights reserved.
#
# OAS DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Analytics Server 7.6.0 (2024)
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1)  jdk-8u401-linux-x64.rpm
#      Download Oracle JDK 1.8.341+ (1.8.401 is used in this image)
#      from https://www.oracle.com/java/technologies/downloads/#java8
# (2)  fmw_12.2.1.4.0_infrastructure_Disk1_1of1.zip
#      Download Oracle WebLogic Server 12.2.1.4 - Fusion Middleware Infrastructure Installer
#      from https://www.oracle.com/middleware/technologies/weblogic-server-installers-downloads.html
# (3)  Oracle_Analytics_Server_Linux_7.6.0.zip
#      Download Oracle Analytics Server 2024 (7.6.0) Installer For Linux x86-64-bit
#      from https://www.oracle.com/solutions/business-analytics/analytics-server/analytics-server.html
# (4)  p28186730_1394214_Generic.zip
#      Download OPatch 13.9.4.2.11+ (13.9.4.2.14 is used in this image)
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=28186730
# (5)  p36178496_122140_Generic.zip
#      Download WLS STACK PATCH BUNDLE 12.2.1.4.240111
#      https://support.oracle.com/epmos/faces/PatchDetail?patchId=36178496
# (6)  p36074941_122140_Generic.zip
#      Download ADF BUNDLE PATCH 12.2.1.4.231205
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=36074941
# (7)  p34809489_122140_Generic.zip
#      Download Fix for CVE-2021-42575 (July 2023)
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=34809489
# (8)  p36034300_122140_Generic.zip
#      Download WebCenter Core Bundle Patch 12.2.1.4.231120
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=36034300
# (9)  p35868571_122140_Generic.zip
#      Download OWSM BUNDLE PATCH 12.2.1.4.231003
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=35868571
# (10) p34542329_122140_Generic.zip
#      Download FMW Control 12.2.1.4 SPU/Merge for Consolidated Updates
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=34542329
# (11) p33950717_122140_Generic.zip
#      Download OPSS BUNDLE PATCH 12.2.1.4.220311
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=33950717
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run:
#      $ docker build -t oracle/oas:7.0.0 .

# Pull base image
# ---------------
FROM oraclelinux:8

# Maintainer
# ----------
LABEL maintainer="Gianni Ceresa <gianni.ceresa@datalysis.ch>"

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV OAS_VERSION="7.6.0"                         \
    ORACLE_BASE=/opt/oracle                     \
    INSTALL_FILE_JDK="jdk-8u401-linux-x64.rpm"  \
    INSTALL_FILE_WLS="fmw_12.2.1.4.0_infrastructure_Disk1_1of1.zip"   \
    INSTALL_FILE_OAS="Oracle_Analytics_Server_Linux_7.6.0.zip"        \
    INSTALL_FILE_OPATCH="p28186730_1394214_Generic.zip"               \
    PATCH_FILE_WLS01="p36178496_122140_Generic.zip"  \
    PATCH_FILE_FMW01="p36074941_122140_Generic.zip"  \
    PATCH_FILE_FMW02="p34809489_122140_Generic.zip"  \
    PATCH_FILE_FMW03="p36034300_122140_Generic.zip"  \
    PATCH_FILE_FMW04="p35868571_122140_Generic.zip"  \
    PATCH_FILE_FMW05="p34542329_122140_Generic.zip"  \
    PATCH_FILE_FMW06="p33950717_122140_Generic.zip"  \
    INSTALL_RSP_WLS="weblogic.rsp"     \
    INSTALL_RSP_OAS="oas_install.rsp"  \
    CONFIG_RSP_OAS="oas_config.rsp"    \
    RUN_FILE="runOAS.sh"

# Use second ENV so that variables get substituted
ENV INSTALL_DIR=${ORACLE_BASE}/install                       \
    ORACLE_HOME=${ORACLE_BASE}/product/${OAS_VERSION}        \
    DOMAIN_HOME=${ORACLE_BASE}/config/domains                \
    BI_EXCEL_EXPORT=${ORACLE_BASE}/bi_excel_export           \
    NODE_PATH=${ORACLE_BASE}/bi_excel_export/node_modules    \
    OAS_FORMATTED_EXPORT_ENABLED=true

# Copy binaries
# -------------
COPY ${INSTALL_FILE_JDK} ${INSTALL_FILE_WLS} ${INSTALL_FILE_OAS} ${INSTALL_FILE_OPATCH} ${PATCH_FILE_WLS01} ${PATCH_FILE_FMW01} ${PATCH_FILE_FMW02} ${PATCH_FILE_FMW03} ${PATCH_FILE_FMW04} ${PATCH_FILE_FMW05} ${PATCH_FILE_FMW06} ${INSTALL_DIR}/
COPY ${INSTALL_RSP_WLS} ${INSTALL_RSP_OAS} ${CONFIG_RSP_OAS} ${RUN_FILE} _configureOAS.sh _validateRCU.sh _dropRCU.sh package.json ${ORACLE_BASE}/

# Setup filesystem and 'oracle' user
# Adjust file permissions, go to 'ORACLE_HOME' as 'oracle' to proceed with OAS installation
# Install pre-req packages + Oracle JDK
# Make sure the run files are executable
# ------------------------------------------
RUN useradd -d /home/oracle -m -s /bin/bash oracle  \
    && echo oracle:oracle | chpasswd                \
    ### Update OS + install required packages
    && dnf -y update  \
    && dnf -y install binutils gcc gcc-c++ glibc glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel libnsl sysstat motif motif-devel redhat-lsb redhat-lsb-core openssl make xorg-x11-utils compat-libgfortran-48  \
    && dnf -y install mesa-libgbm at-spi2-atk       \
    ### Install JDK
    && dnf -y install ${INSTALL_DIR}/${INSTALL_FILE_JDK}  \
    && dnf clean all                                      \
    && rm ${INSTALL_DIR}/${INSTALL_FILE_JDK}              \
    ### Install NodeJs (and PM2)
    && dnf module enable -y nodejs:20  \
    && dnf install -y nodejs           \
    && npm install pm2@latest -g       \
    ### Prepare directories
    && mkdir -p ${ORACLE_BASE}  \
    && mkdir -p ${ORACLE_HOME}  \
    && mkdir -p ${DOMAIN_HOME}  \
    ### oraInst.loc file
    && touch ${ORACLE_BASE}/oraInst.loc                                             \
    && echo inventory_loc=${ORACLE_BASE}/oraInventory > ${ORACLE_BASE}/oraInst.loc  \
    && echo inst_group=oracle >> ${ORACLE_BASE}/oraInst.loc                         \
    ### Directories ownership + permissions for scripts
    && chown -R oracle. ${ORACLE_BASE}  \
    && chown -R oracle. ${ORACLE_HOME}  \
    && chown -R oracle. ${DOMAIN_HOME}  \
    && chmod ug+x ${ORACLE_BASE}/*.sh

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
RUN cd ${INSTALL_DIR}  \
    ### Install WLS-FMW
    && unzip ${INSTALL_DIR}/${INSTALL_FILE_WLS} -d ${INSTALL_DIR}/tmp_wls                                                                                  \
    && rm ${INSTALL_DIR}/${INSTALL_FILE_WLS}                                                                                                               \
    && java -jar $(find ${INSTALL_DIR}/tmp_wls -name *.jar) -silent -responseFile ${ORACLE_BASE}/${INSTALL_RSP_WLS} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && rm -rf ${INSTALL_DIR}/tmp_wls                                                                                                                       \
    ### Install OAS
    && unzip ${INSTALL_DIR}/${INSTALL_FILE_OAS} -d ${INSTALL_DIR}/tmp_oas                                                                                  \
    && rm ${INSTALL_DIR}/${INSTALL_FILE_OAS}                                                                                                               \
    && java -jar $(find ${INSTALL_DIR}/tmp_oas -name Oracle_Analytics_Server_2024_Linux.jar) -silent -responseFile ${ORACLE_BASE}/${INSTALL_RSP_OAS} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && rm -rf ${INSTALL_DIR}/tmp_oas                                                                                                                       \
    ### Update OPatch
    && unzip ${INSTALL_DIR}/${INSTALL_FILE_OPATCH} -d ${INSTALL_DIR}/tmp_opatch                                                                       \
    && rm ${INSTALL_DIR}/${INSTALL_FILE_OPATCH}                                                                                                       \
    && java -jar $(find ${INSTALL_DIR}/tmp_opatch -name opatch_generic.jar) -silent oracle_home=${ORACLE_HOME} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && rm -rf ${INSTALL_DIR}/${INSTALL_DIR}/tmp_opatch                                                                                                \
    ### Patch WLS
    # - patch 1
    && unzip ${INSTALL_DIR}/${PATCH_FILE_WLS01} -d ${INSTALL_DIR}/patch                                  \
    && rm ${INSTALL_DIR}/${PATCH_FILE_WLS01}                                                             \
    && cd $(find ${INSTALL_DIR}/patch -type d -name binary_patches)                                      \
    && ${ORACLE_HOME}/OPatch/opatch napply -silent -oh ${ORACLE_HOME} -phBaseFile linux64_patchlist.txt  \
    && cd ${INSTALL_DIR}                                                                                 \
    && rm -rf ${INSTALL_DIR}/patch                                                                       \
    ### Patch FMW
    # - patch 1
    && unzip ${INSTALL_DIR}/${PATCH_FILE_FMW01} -d ${INSTALL_DIR}/patch                  \
    && rm ${INSTALL_DIR}/${PATCH_FILE_FMW01}                                             \
    && cd $(find ${INSTALL_DIR}/patch -maxdepth 1 -type d -name '*[0-9]*')               \
    && ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && cd ${INSTALL_DIR}                                                                 \
    && rm -rf ${INSTALL_DIR}/patch                                                       \
    # - patch 2
    && unzip ${INSTALL_DIR}/${PATCH_FILE_FMW02} -d ${INSTALL_DIR}/patch                  \
    && rm ${INSTALL_DIR}/${PATCH_FILE_FMW02}                                             \
    && cd $(find ${INSTALL_DIR}/patch -maxdepth 1 -type d -name '*[0-9]*')               \
    && ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && cd ${INSTALL_DIR}                                                                 \
    && rm -rf ${INSTALL_DIR}/patch                                                       \
    # - patch 3
    && unzip ${INSTALL_DIR}/${PATCH_FILE_FMW03} -d ${INSTALL_DIR}/patch                  \
    && rm ${INSTALL_DIR}/${PATCH_FILE_FMW03}                                             \
    && cd $(find ${INSTALL_DIR}/patch -maxdepth 1 -type d -name '*[0-9]*')               \
    && ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && cd ${INSTALL_DIR}                                                                 \
    && rm -rf ${INSTALL_DIR}/patch                                                       \
    # - patch 4
    && unzip ${INSTALL_DIR}/${PATCH_FILE_FMW04} -d ${INSTALL_DIR}/patch                  \
    && rm ${INSTALL_DIR}/${PATCH_FILE_FMW04}                                             \
    && cd $(find ${INSTALL_DIR}/patch -maxdepth 1 -type d -name '*[0-9]*')               \
    && ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && cd ${INSTALL_DIR}                                                                 \
    && rm -rf ${INSTALL_DIR}/patch                                                       \
    # - patch 5
    && unzip ${INSTALL_DIR}/${PATCH_FILE_FMW05} -d ${INSTALL_DIR}/patch                  \
    && rm ${INSTALL_DIR}/${PATCH_FILE_FMW05}                                             \
    && cd $(find ${INSTALL_DIR}/patch -maxdepth 1 -type d -name '*[0-9]*')               \
    && ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && cd ${INSTALL_DIR}                                                                 \
    && rm -rf ${INSTALL_DIR}/patch                                                       \
    # - patch 6
    && unzip ${INSTALL_DIR}/${PATCH_FILE_FMW06} -d ${INSTALL_DIR}/patch                  \
    && rm ${INSTALL_DIR}/${PATCH_FILE_FMW06}                                             \
    && cd $(find ${INSTALL_DIR}/patch -maxdepth 1 -type d -name '*[0-9]*')               \
    && ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && cd ${INSTALL_DIR}                                                                 \
    && rm -rf ${INSTALL_DIR}/patch                                                       \
    # clean up
    && cd ${ORACLE_BASE}                                                                 \
    && rm -rf ${INSTALL_DIR}                                                             \
    ### Install NodeJs modules for BI Excel export
    && mkdir -p ${BI_EXCEL_EXPORT}                                                       \
    && cd ${BI_EXCEL_EXPORT}                                                             \
    && mv ${ORACLE_BASE}/package.json ${BI_EXCEL_EXPORT}/                                \
    && npm install

# Set work directory
# ------------------
WORKDIR ${ORACLE_BASE}

# Expose ports
# ------------
EXPOSE 9500-9514

# Define default command to start OAS
# -----------------------------------
CMD ${ORACLE_BASE}/${RUN_FILE}
