# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2026 DATAlysis LLC (https://datalysis.ch). All rights reserved.
#
# OAS DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Analytics Server 26.01.0.0.0 (2026)
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1)  jdk-21.0.10_linux-x64_bin.rpm
#      Download Oracle JDK 21.0.10
#      from https://www.oracle.com/java/technologies/downloads/#java21
# (2)  fmw_14.1.2.0.0_infrastructure.zip
#      Download Oracle WebLogic Server 14.1.2.0 - Fusion Middleware Infrastructure Installer
#      from https://www.oracle.com/middleware/technologies/weblogic-server-installers-downloads.html
# (3)  Oracle_Analytics_Server_2026_Linux.zip
#      Download Oracle Analytics Server 2026 (26.01.0.0.0) Installer For Linux x86-64-bit
#      from https://www.oracle.com/solutions/analytics/analytics-server/analytics-server.html
# (4)  p28186730_1394222_Generic.zip
#      Download OPatch 13.9.4.2.17+ (13.9.4.2.22 is used in this image)
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=28186730
# (5)  p38799629_141200_Generic.zip
#      Download WLS STACK PATCH BUNDLE 14.1.2.0.251226
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=38799629
# (6)  p38566996_141200_Generic.zip
#      Download UMS Bundle Patch 14.1.2.0.251022
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=38566996
# (7)  p38348367_141200_Generic.zip
#      Download ADF BUNDLE PATCH 14.1.2.0.250823
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=38348367
# (8)  p38679562_141200_Generic.zip
#      Download OWSM BUNDLE PATCH 14.1.2.0.251120
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=38679562
# (9)  p38637356_141200_Generic.zip
#      Download FMWCONTROL BUNDLE PATCH 14.1.2.0.260120
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=38637356
# (10) p38391376_141200_Generic.zip
#      Download STACK:FMW:RCU prereq steps fails while trying to validate the DB connection
#      from https://support.oracle.com/epmos/faces/PatchDetail?patchId=38391376
#
# There could be newer patches available:
# - a list of patches for WebLogic and FMW 14.1.2.0 is available at https://support.oracle.com/ic/builder/rt/customer_portal/live/webApps/customer-portal/?anchorId=&documentId=KA1182
# - a list of patches for OAS 2026 is available at https://support.oracle.com/support/?page=sptemplate&sptemplate=km-article&documentId=KA973
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run:
#      $ docker build -t oracle/oas:26.01.0.0.0 .

# Pull base image
# ---------------
FROM oraclelinux:9

# Maintainer
# ----------
LABEL maintainer="Gianni Ceresa <gianni.ceresa@datalysis.ch>"

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV OAS_VERSION="26.01.0.0.0"                         \
    ORACLE_BASE=/opt/oracle                     \
    INSTALL_FILE_JDK="jdk-21.0.10_linux-x64_bin.rpm"  \
    INSTALL_FILE_WLS="fmw_14.1.2.0.0_infrastructure.zip"   \
    INSTALL_FILE_OAS="Oracle_Analytics_Server_2026_Linux.zip"        \
    INSTALL_FILE_OPATCH="p28186730_1394222_Generic.zip"               \
    PATCH_FILE_WLS01="p38799629_141200_Generic.zip"  \
    PATCH_FILE_FMW01="p38566996_141200_Generic.zip"  \
    PATCH_FILE_FMW02="p38348367_141200_Generic.zip"  \
    PATCH_FILE_FMW03="p38679562_141200_Generic.zip"  \
    PATCH_FILE_FMW04="p38637356_141200_Generic.zip"  \
    PATCH_FILE_RCU01="p38391376_141200_Generic.zip"  \
    INSTALL_RSP_WLS="weblogic.rsp"     \
    INSTALL_RSP_OAS="oas_install.rsp"  \
    CONFIG_RSP_OAS="oas_config.rsp"    \
    RUN_FILE="runOAS.sh"

# Use second ENV so that variables get substituted
ENV INSTALL_DIR=${ORACLE_BASE}/install                 \
    ORACLE_HOME=${ORACLE_BASE}/product/${OAS_VERSION}  \
    DOMAIN_HOME=${ORACLE_BASE}/config/domains          \
    NODEJS_MODULES=${ORACLE_BASE}/nodejs

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
    && dnf -y update                  \
    && dnf -y install hostname unzip  \
    && dnf -y install binutils gcc gcc-c++ glibc glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel libnsl sysstat motif motif-devel openssl make xorg-x11-utils ksh libcap libgfortran libxcrypt-compat  \
    ### Install JDK
    && dnf -y install ${INSTALL_DIR}/${INSTALL_FILE_JDK}  \
    && rm ${INSTALL_DIR}/${INSTALL_FILE_JDK}              \
    ### Install NodeJs (and PM2)
    && dnf module enable -y nodejs:24  \
    && dnf install -y nodejs npm       \
    && npm install pm2@latest -g       \
    ### Install a number of requirements for the Node.js puppetter (chromium) package
    && dnf install -y nspr nss atk at-spi2-atk cups-libs libxkbcommon libXdamage mesa-libgbm pango alsa-lib  \
    ## Fix an issue with DV python packages
    && ln -s libffi.so.8 /usr/lib64/libffi.so.6  \
    && dnf clean all            \
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
    sed -i -e "s|###DOMAIN_HOME###|${DOMAIN_HOME}|g"   ${ORACLE_BASE}/${CONFIG_RSP_OAS}

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
    && java -jar $(find ${INSTALL_DIR}/tmp_oas -name *Linux.jar) -silent -responseFile ${ORACLE_BASE}/${INSTALL_RSP_OAS} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
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
    ### Patch RCU
    # - patch 1
    && unzip ${INSTALL_DIR}/${PATCH_FILE_RCU01} -d ${INSTALL_DIR}/patch                  \
    && rm ${INSTALL_DIR}/${PATCH_FILE_RCU01}                                             \
    && cd $(find ${INSTALL_DIR}/patch -maxdepth 1 -type d -name '*[0-9]*')               \
    && ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  \
    && cd ${INSTALL_DIR}                                                                 \
    && rm -rf ${INSTALL_DIR}/patch                                                       \
    # clean up
    && cd ${ORACLE_BASE}                                                                 \
    && rm -rf ${INSTALL_DIR}                                                             \
    ### Node.js modules
    && mkdir -p ${NODEJS_MODULES}                                                        \
    && mv ${ORACLE_BASE}/package.json ${NODEJS_MODULES}/package.json                     \
    && cd ${NODEJS_MODULES}                                                              \
    && npm install

# Set work directory
# ------------------
WORKDIR ${ORACLE_BASE}

# Expose ports
# ------------
EXPOSE 9500-9515

# Define default command to start OAS
# -----------------------------------
CMD ${ORACLE_BASE}/${RUN_FILE}
