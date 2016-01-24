# Kafka-Dockerfile

# ---- Version control ----

FROM xpatterns/java:7u79

ENV USER kafka
ENV KAFKA_VERSION kafka_2.10-0.8.2.1
ENV KAFKA_DOWNLOAD http://apache.osuosl.org/kafka/0.8.2.1/kafka_2.10-0.8.2.1.tgz


# ---- Default Environmental Variables ----

ENV ZOOKEEPER_HOST localhost
ENV ZOOKEEPER_PORT 2181
ENV ZOOKEEPER_CONNECTION_TIMEOUT 6000
ENV GROUP_ID test-consumer-group
ENV METADATA_BROKER_HOST localhost
ENV METADATA_BROKER_PORT 9092
ENV PRODUCER_TYPE sync
ENV COMPRESSION_CODEC none
ENV BROKER_ID 0
ENV NUM_NETWORK_THREADS 3
ENV NUM_IO_THREADS 8
ENV SEND_BUFFER 102400
ENV RECEIVE_BUFFER 102400
ENV REQUEST_MAX_BUFFER 104857600
ENV NUM_PARTITIONS 1
ENV LOG_RETENTION_HOURS 168


# ---- Ports ----

EXPOSE ${METADATA_BROKER_PORT}


# ---- apt-get ----

RUN apt-get update && apt-get install -y wget


# ---- Setup $USER ----

RUN useradd $USER -U
RUN echo $USER:$USER | chpasswd
RUN mkdir /home/$USER && chown $USER:$USER /home/$USER


# ---- Setup Kafka ----

RUN wget $KAFKA_DOWNLOAD  -P /tmp/
RUN tar zxvf /tmp/$KAFKA_VERSION.tgz -C /usr/local/
RUN rm -Rf /tmp/*

RUN chown -R $USER:$USER /usr/local/$KAFKA_VERSION


# ---- Setup the startup script ----

RUN mkdir -p /tmp/kafka-logs/

COPY conf/run.sh /usr/bin/run.sh
RUN chmod u+x /usr/bin/run.sh
ENTRYPOINT ["/usr/bin/run.sh"]
CMD ["run"]
