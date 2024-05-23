# Based on: https://github.com/brandonstevens/mirth-connect-docker
# To execute:
#  docker run -d -P -v ~/mirth.properties:/opt/mirth-connect/conf/mirth.properties \
#         -v ~/configurationMap.properties:/opt/mirth-connect/appdata/configurationMap.properties cmx-mirth-standalone:latest
FROM cmx-java-service-base

ENV MIRTH_CONNECT_VERSION 3.6.1.b220
ENV MIRTH_CLUSTERING_VERSION 3.6.1.b236
ENV MIRTH_SSL_MANAGER_VERSION 3.6.1.b266
ENV MIRTH_ADVANCED_ALERT_PLUGIN_VERSION 3.6.1.b228
ENV MIRTH_AUTHORIZATION_PLUGIN_VERSION 3.6.1.b223

# Mirth Connect is run with user `mirth`, uid = 1000
# If you bind mount a volume from the host or a data container, ensure you use the same uid
RUN adduser -D -u 1000 mirth

RUN \
  cd /tmp && \
  wget http://downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  tar xvzf mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  rm -f mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  mkdir /opt/mirth-connect/ && \
  mv "Mirth Connect"/* /opt/mirth-connect/ && \
  chown -R mirth /opt/mirth-connect

WORKDIR /opt/mirth-connect

EXPOSE 8080 8443

COPY files/keystore.jks /opt/mirth-connect/appdata/

# Mirth Advanced Clustering Plugin
#COPY files/clusteringadvanced-$MIRTH_CLUSTERING_VERSION.zip /opt/mirth-connect/
#RUN unzip clusteringadvanced-$MIRTH_CLUSTERING_VERSION.zip && \
#      mv /opt/mirth-connect/clusteringadvanced /opt/mirth-connect/extensions/clusteringadvanced

# Mirth SSL Manager Plugin
COPY files/ssl-$MIRTH_SSL_MANAGER_VERSION.zip /opt/mirth-connect/
RUN unzip ssl-$MIRTH_SSL_MANAGER_VERSION.zip && \
      mv /opt/mirth-connect/ssl /opt/mirth-connect/extensions/ssl

# Mirth Advanced Alerting Plugin
COPY files/alert-$MIRTH_ADVANCED_ALERT_PLUGIN_VERSION.zip /opt/mirth-connect/
RUN unzip alert-$MIRTH_ADVANCED_ALERT_PLUGIN_VERSION.zip && \
      mv /opt/mirth-connect/alert /opt/mirth-connect/extensions/alert

# Mirth authorization plugin
COPY files/auth-$MIRTH_AUTHORIZATION_PLUGIN_VERSION.zip /opt/mirth-connect/
RUN unzip auth-$MIRTH_AUTHORIZATION_PLUGIN_VERSION.zip && \
      mv /opt/mirth-connect/auth /opt/mirth-connect/extensions/auth

COPY scripts/cmx-mirth.sh /
RUN chmod +x /cmx-mirth.sh

ENTRYPOINT ["/cmx-mirth.sh"]

CMD ["java", "-jar", "mirth-server-launcher.jar"]
