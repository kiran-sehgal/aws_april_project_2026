Java Version Configuration

This project supports multiple Java versions through Maven properties and the Dockerfile.

## Build with Different Java Versions

### Using Maven CLI

Build with a specific Java version:
~~~bash
mvn clean package -Djava.version=21
mvn clean package -Djava.version=17
mvn clean package -Djava.version=11
mvn clean package -Djava.version=8
~~~

### Using Docker

Build Docker image with a specific Java version:
~~~bash
docker build --build-arg JAVA_VERSION=21 -t aws-project:java21 .
docker build --build-arg JAVA_VERSION=17 -t aws-project:java17 .
docker build --build-arg JAVA_VERSION=11 -t aws-project:java11 .
~~~

## Notes

- The current Dockerfile defaults to Tomcat 9 and Java 21.
- Java version support is configured through Maven property -Djava.version.
- Jenkins parameters are not available in this repository version.

## Java Version Compatibility

| Java Version | Tomcat 9 | Tomcat 10 | Min Maven |
|--------------|----------|-----------|-----------|
| 8 | ✓ | ✗ | 3.5.0 |
| 11 | ✓ | ✓ | 3.6.0 |
| 17 | ✓ | ✓ | 3.8.1 |
| 21 | ✓ | ✓ | 3.9.0 |

## Troubleshooting

- If the Maven build fails for Java 21, verify Maven 3.9.0+ is installed.
- If Docker build fails, ensure Docker is running and the base image is available.
~~~bash
docker pull tomcat:9-jdk21-temurin
~~~
