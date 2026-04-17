AWS Project Build Guide

This repository is a Maven-based Java web application. The guide below covers the current build and deployment workflow for the project.

## Overview

The project includes the application source, Maven configuration, a Dockerfile, and Kubernetes manifests.
It does not include build scripts or a Jenkinsfile in the current repository state.

## Prerequisites

- Java: OpenJDK 21 (or Java 8, 11, 17 as needed)
- Maven: 3.9.0 or higher
- Git: For cloning the repository
- Docker: Optional for container builds
- kubectl: Optional for Kubernetes deployment

## Build the Project

### Standard build
~~~bash
mvn clean package
~~~

### Build with a specific Java version
~~~bash
mvn clean package -Djava.version=17
~~~

### Skip tests
~~~bash
mvn clean package -DskipTests
~~~

## Running Locally

### Use the Jetty plugin
~~~bash
cd webapp
mvn jetty:run
~~~

### Deploy to Tomcat
1. Build the WAR:
~~~bash
mvn clean package
~~~
2. Copy webapp/target/webapp.war to /webapps/
3. Start Tomcat
4. Open http://localhost:8080/webapp

## Docker Deployment

Build the Docker image:
~~~bash
docker build -t aws-project:latest .
~~~

Run the Docker container:
~~~bash
docker run -d -p 8080:8080 aws-project:latest
~~~

## Kubernetes Deployment

Apply the manifests:
~~~bash
kubectl apply -f regapp-deploy.yml
kubectl apply -f regapp-service.yml
~~~

## Notes

- Jenkins and docker-compose support are not included in this repo version.
- Use Maven directly for build and package operations.
- Docker and Kubernetes are optional deployment paths.

