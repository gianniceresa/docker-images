FROM apache/zeppelin:0.7.2

LABEL maintainer="Gianni Ceresa <gianni.ceresa@datalysis.ch>"

COPY pgx-2.4.1-zeppelin-interpreter.zip pgx-2.4.1-server.zip runZeppelinPGX.sh /opt/pgx/

ENV PGX_HOME=/opt/pgx  \
    PGX_VERSION="pgx-2.4.1"  \
    FILE_PGX_INTERPRETER="pgx-2.4.1-zeppelin-interpreter.zip"  \
    FILE_PGX_SERVER="pgx-2.4.1-server.zip"  \
    RUN_FILE="runZeppelinPGX.sh"

RUN unzip $PGX_HOME/$FILE_PGX_SERVER -d $PGX_HOME && \
    rm $PGX_HOME/$FILE_PGX_SERVER && \
    unzip $PGX_HOME/$FILE_PGX_INTERPRETER -d /zeppelin/interpreter/pgx  && \
    rm $PGX_HOME/$FILE_PGX_INTERPRETER  && \
    cd /opt  && \
    wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64  && \
    chmod +x jq  && \
    mv jq /usr/bin  && \
    cd $PGX_HOME/$PGX_VERSION/conf && \
    mv server.conf server.conf.old && \
    jq '.enable_client_authentication = false | .enable_tls = false' server.conf.old > server.conf  && \
    mv pgx.conf pgx.conf.old  && \
    jq '. + {allow_local_filesystem: true}' pgx.conf.old > pgx.conf && \
    jq '.[0].properties["pgx.baseUrl"].defaultValue = "http://localhost:7007"' /zeppelin/interpreter/pgx/interpreter-setting.json > /zeppelin/interpreter/pgx/interpreter-setting.json.new  && \
    mv /zeppelin/interpreter/pgx/interpreter-setting.json.new /zeppelin/interpreter/pgx/interpreter-setting.json  && \
    apt-get install xmlstarlet  && \
    echo '<?xml version="1.0"?>' > /zeppelin/conf/zeppelin-site.xml  && \
    echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> /zeppelin/conf/zeppelin-site.xml  && \
    echo '<configuration>' >> /zeppelin/conf/zeppelin-site.xml  && \
    xmlstarlet sel -t -c "/configuration/property[name='zeppelin.interpreters']" /zeppelin/conf/zeppelin-site.xml.template >> /zeppelin/conf/zeppelin-site.xml  && \
    echo '</configuration>' >> /zeppelin/conf/zeppelin-site.xml  && \
    sed -i -e "s|</value>|,oracle.pgx.zeppelin.PgxInterpreter</value>|g" /zeppelin/conf/zeppelin-site.xml && \
    chmod +x $PGX_HOME/$RUN_FILE

EXPOSE 8080/tcp 7007/tcp
WORKDIR /zeppelin
CMD $PGX_HOME/$RUN_FILE
