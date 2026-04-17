# Build arguments
ARG JAVA_VERSION=21
ARG TOMCAT_VERSION=10

# Stage 1: Build
FROM maven:3.9.6-eclipse-temurin-${JAVA_VERSION} AS builder
WORKDIR /workspace

COPY pom.xml ./
COPY .mvn .mvn
COPY server/pom.xml server/pom.xml
COPY webapp/pom.xml webapp/pom.xml
COPY server/src server/src
COPY webapp/src webapp/src

RUN mvn -B clean package \
    -DskipTests \
    -Djava.version=${JAVA_VERSION} \
    -Dmaven.compiler.source=${JAVA_VERSION} \
    -Dmaven.compiler.target=${JAVA_VERSION} \
    -Dmaven.compiler.release=${JAVA_VERSION} \
    --batch-mode

# Stage 2: Runtime
ARG JAVA_VERSION
ARG TOMCAT_VERSION
FROM tomcat:${TOMCAT_VERSION}-jdk${JAVA_VERSION}-temurin AS runtime

RUN set -e && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

RUN set -e && \
    cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps && \
    echo "Tomcat ${TOMCAT_VERSION} with Java ${JAVA_VERSION} ready"

COPY --from=builder /workspace/webapp/target/webapp.war /usr/local/tomcat/webapps/

RUN ls -la /usr/local/tomcat/webapps/*.war

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

CMD ["catalina.sh", "run"]