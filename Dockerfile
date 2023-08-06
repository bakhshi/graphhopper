FROM maven:3.9.3-eclipse-temurin-20 as build

RUN apt-get install -y wget

WORKDIR /graphhopper

COPY . .

RUN mvn clean install -DskipTests=true

FROM openjdk:20

ENV JAVA_OPTS "-Xmx1g -Xms1g -Ddw.server.application_connectors[0].bind_host=0.0.0.0 -Ddw.server.application_connectors[0].port=8989"

ENV TOOL_OPTS "-Ddw.graphhopper.datareader.file=europe_germany_berlin.pbf -Ddw.graphhopper.graph.location=default-gh"

RUN mkdir -p /data

WORKDIR /graphhopper

COPY --from=build /graphhopper/web/target/graphhopper*.jar ./

COPY ./config-example.yml ./

VOLUME [ "/data" ]

EXPOSE 8989

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8989/health || exit 1

ENTRYPOINT [ "java $JAVA_OPTS $TOOL_OPTS -jar *.jar", "server config-example.yml" ]
