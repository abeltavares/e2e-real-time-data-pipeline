FROM flink:1.18.1-scala_2.12-java11

RUN curl -o ${FLINK_HOME}/lib/flink-sql-connector-kafka-3.1.0-1.18.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.1.0-1.18/flink-sql-connector-kafka-3.1.0-1.18.jar && \
    curl -o ${FLINK_HOME}/lib/flink-json-1.18.1.jar https://repo.maven.apache.org/maven2/org/apache/flink/flink-json/1.18.1/flink-json-1.18.1.jar && \
    curl -o ${FLINK_HOME}/lib/iceberg-flink-runtime-1.18-1.5.0.jar https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.18/1.5.0/iceberg-flink-runtime-1.18-1.5.0.jar && \
    curl -o ${FLINK_HOME}/lib/hadoop-common-2.8.3.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/2.8.3/hadoop-common-2.8.3.jar && \
    curl -o ${FLINK_HOME}/lib/hadoop-hdfs-2.8.3.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs/2.8.3/hadoop-hdfs-2.8.3.jar && \
    curl -o ${FLINK_HOME}/lib/hadoop-client-2.8.3.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client/2.8.3/hadoop-client-2.8.3.jar && \
    curl -o ${FLINK_HOME}/lib/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/2.8.3-10.0/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar && \
    curl -o ${FLINK_HOME}/lib/bundle-2.20.18.jar https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.20.18/bundle-2.20.18.jar

WORKDIR /opt/flink

CMD ["bash", "-c", "${FLINK_HOME}/bin/sql-client.sh && tail -f /dev/null"]
