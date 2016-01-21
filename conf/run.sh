#!/bin/bash
# This is the base process of the container.

build_config()
{
cat > /usr/local/$KAFKA_VERSION/config/consumer.properties<< EOF
zookeeper.connect=${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT}
zookeeper.connection.timeout.ms=${ZOOKEEPER_CONNECTION_TIMEOUT}
group.id=${GROUP_ID}
EOF

cat > /usr/local/$KAFKA_VERSION/config/producer.properties<< EOF
metadata.broker.list=${METADATA_BROKER_HOST}:${METADATA_BROKER_PORT}
producer.type=${PRODUCER_TYPE}
compression.codec=${COMPRESSION_CODEC}
serializer.class=kafka.serializer.DefaultEncoder
EOF

cat > /usr/local/$KAFKA_VERSION/config/server.properties<< EOF
broker.id=${BROKER_ID}
port=${METADATA_BROKER_PORT}
num.network.threads=${NUM_NETWORK_THREADS}
num.io.threads=${NUM_IO_THREADS}
socket.send.buffer.bytes=${SEND_BUFFER}
socket.receive.buffer.bytes=${RECEIVE_BUFFER}
socket.request.max.bytes=${REQUEST_MAX_BUFFER}
log.dirs=/tmp/kafka-logs
num.partitions=${NUM_PARTITIONS}
num.recovery.threads.per.data.dir=1
log.retention.hours=${LOG_RETENTION_HOURS}
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
log.cleaner.enable=false
zookeeper.connect=${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT}
zookeeper.connection.timeout.ms=${ZOOKEEPER_CONNECTION_TIMEOUT}
EOF
}

prereques()
{
	while ! exec 6<>/dev/tcp/${ZOOKEEPER_HOST}/${ZOOKEEPER_PORT}; do
	   echo "$(date) - still waiting for the zookeeper service at ${ZOOKEEPER_HOST}"
	   sleep 10
	done
}


# Initalize the container
init_container()
{ 
        build_config
        start_container
}

# Start everything and tail logs to keep PID 1 going.
start_container() 
{
	start_all
	sleep 1
	tail -f /tmp/kafka-logs/kafka.out
}

# Start the all service
start_all() 
{
	prereques
	cd /usr/local/$KAFKA_VERSION/ && bin/kafka-server-start.sh config/server.properties &> /tmp/kafka-logs/kafka.out&
}

# Stop the all service
stop_all() 
{
	echo "TODO"	
}


# Startup the container
if [ -z $1 ] || [ "$1" == "run" ]; then
	start_container
fi

# Initalize the container
if [ "$1" == "init" ]; then 
	init_container	
fi

# Start all
if [ "$1" == "start" ]; then 
	start_all
fi

# Stop all
if [ "$1" == "stop" ]; then 
	stop_all
fi

# Restart all
if [ "$1" == "restart" ]; then 
	stop_all
	sleep 2
	start_all
fi
