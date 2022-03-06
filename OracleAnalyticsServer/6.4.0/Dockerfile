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
    INSTALL_FILE_JDK="jdk-8u311-linux-x64.rpm"  \
    INSTALL_FILE_WLS="fmw_12.2.1.4.0_infrastructure_Disk1_1of1.zip" \
    INSTALL_FILE_WLS_PATCH="p30657796_122140_Generic.zip"           \
    INSTALL_FILE_OAS="Oracle_Analytics_Server_Linux_6.4.0.zip"      \
    INSTALL_FILE_OWSM_PATCH="p33618954_122140_Generic.zip"          \
    INSTALL_FILE_FMW_PATCH_1="p33751264_122140_Generic.zip"         \
    INSTALL_FILE_FMW_PATCH_2="p33735326_12214220105_Generic.zip"    \
    INSTALL_FILE_FMW_PATCH_3="p33791665_12214220105_Generic.zip"    \
    INSTALL_FILE_OPATCH="p28186730_139428_Generic.zip"              \
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
COPY ${INSTALL_FILE_JDK} ${INSTALL_FILE_WLS} ${INSTALL_FILE_WLS_PATCH} ${INSTALL_FILE_OAS} ${INSTALL_FILE_OWSM_PATCH} ${INSTALL_FILE_FMW_PATCH_1} ${INSTALL_FILE_FMW_PATCH_2} ${INSTALL_FILE_FMW_PATCH_3} ${INSTALL_FILE_OPATCH} ${INSTALL_DIR}/
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
#RUN cd ${INSTALL_DIR}                      && \
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
    unzip ${INSTALL_FILE_OPATCH} -d ${INSTALL_DIR}/tmp_opatch  && \
    rm ${INSTALL_FILE_OPATCH}               && \
    java -jar ${INSTALL_DIR}/tmp_opatch/6880880/opatch_generic.jar -silent oracle_home=${ORACLE_HOME} -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    rm -rf ${INSTALL_DIR}/tmp_opatch        && \
    unzip ${INSTALL_FILE_OWSM_PATCH} -d ${INSTALL_DIR}/owsm_patch  && \
    rm ${INSTALL_FILE_OWSM_PATCH}           && \
    cd ${INSTALL_DIR}/owsm_patch/33618954   && \
    ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    cd ${INSTALL_DIR}                       && \
    rm -rf ${INSTALL_DIR}/owsm_patch        && \
    unzip ${INSTALL_FILE_FMW_PATCH_1} -d ${INSTALL_DIR}/patch1 && \
    rm ${INSTALL_FILE_FMW_PATCH_1} && \
    cd ${INSTALL_DIR}/patch1/WLS_SPB_12.2.1.4.220112/binary_patches && \
    ${ORACLE_HOME}/OPatch/opatch napply -silent -oh ${ORACLE_HOME} -phBaseFile linux64_patchlist.txt && \
    cd ${INSTALL_DIR}                       && \
    rm -rf ${INSTALL_DIR}/patch1            && \
    unzip ${INSTALL_FILE_FMW_PATCH_2} -d ${INSTALL_DIR}/patch2  && \
    rm ${INSTALL_FILE_FMW_PATCH_2}          && \
    cd ${INSTALL_DIR}/patch2/33735326       && \
    ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    cd ${INSTALL_DIR}                       && \
    rm -rf ${INSTALL_DIR}/patch2            && \
    unzip ${INSTALL_FILE_FMW_PATCH_3} -d ${INSTALL_DIR}/patch3  && \
    rm ${INSTALL_FILE_FMW_PATCH_3}          && \
    cd ${INSTALL_DIR}/patch3/33791665       && \
    ${ORACLE_HOME}/OPatch/opatch apply -silent -invPtrLoc ${ORACLE_BASE}/oraInst.loc  && \
    cd ${INSTALL_DIR}                       && \
    rm -rf ${INSTALL_DIR}/patch3            && \
    rm -rf ${INSTALL_DIR}

# Set work directory
# ------------------
WORKDIR ${ORACLE_BASE}

# Expose ports
# ------------
EXPOSE 9500-9514

# Define default command to start OAS
# -----------------------------------
#CMD ${ORACLE_BASE}/${RUN_FILE}
CMD bash

