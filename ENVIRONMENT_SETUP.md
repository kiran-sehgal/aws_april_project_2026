Environment Setup Guide

This guide covers the current environment setup for building and running the AWS Project.

## Local Development Setup

### Windows

1. Install Java 21 or another supported version.
2. Install Maven 3.9.0 or higher.
3. Add Java and Maven to PATH.
4. Verify:
~~~bash
java -version
mvn -version
~~~

### macOS

1. Install Java using Homebrew or installer.
2. Install Maven using Homebrew or binary distribution.
3. Verify:
~~~bash
java -version
mvn -version
~~~

### Linux

1. Install Java (OpenJDK 21 or a supported version).
2. Install Maven 3.9.0+ from package manager or binary.
3. Verify:
~~~bash
java -version
mvn -version
~~~

## Build the Project

From the project root:
~~~bash
mvn clean package
~~~

To build with a specific Java version:
~~~bash
mvn clean package -Djava.version=17
~~~

## Docker Optional

Docker is optional. If installed, use the included Dockerfile to build an image:
~~~bash
docker build -t aws-project:latest .
~~~

## Kubernetes Optional

Kubernetes manifests are included under the repository root. Use kubectl to apply them if you have a cluster available.
~~~bash
kubectl apply -f regapp-deploy.yml
kubectl apply -f regapp-service.yml
~~~

## Notes

- This repository does not include build scripts such as build.sh or build.bat.
- There is no Jenkinsfile or docker-compose.yml in this version of the repo.
- Use Maven directly for build and package tasks.

