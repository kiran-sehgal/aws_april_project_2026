AWS Project - Registration Application

A Java Maven web application for registration management. This project contains the application source, Maven configuration, a Dockerfile for container packaging, and Kubernetes manifests for deployment.

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Building the Project](#building-the-project)
- [Running Locally](#running-locally)
- [Docker Deployment](#docker-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Troubleshooting](#troubleshooting)

---

## Project Overview

This repository contains a Java web application built with Maven. The application is packaged as a WAR and is designed to run on Tomcat.

## Tech Stack

| Component | Technology | Notes |
|-----------|------------|-------|
| Java | OpenJDK | Compatible with Java 8-21 via Maven configuration |
| Build Tool | Maven | 3.9.0+ recommended |
| Web Server | Tomcat | 9 (recommended) |
| Servlet API | javax.servlet | Provided by Tomcat |
| Testing | JUnit, Hamcrest, Mockito | Unit testing support |
| Containerization | Docker | Optional, Dockerfile included |
| Orchestration | Kubernetes | Optional manifests included |

## Prerequisites

- Java: OpenJDK 21 (or Java 8, 11, 17 as needed)
- Maven: 3.9.0 or higher
- Git: For cloning the repository
- Docker: Optional, to build and run the Docker image
- kubectl: Optional, to apply Kubernetes manifests

## Project Structure

```
aws-project/
├── .mvn/
├── Dockerfile
├── pom.xml
├── README.md
├── BUILD_GUIDE.md
├── ENVIRONMENT_SETUP.md
├── JAVA_VERSION_CONFIG.md
├── regapp-deploy.yml
├── regapp-service.yml
├── server/
│   ├── pom.xml
│   └── src/
│       ├── main/java/com/example/
│       │   └── Greeter.java
│       └── test/java/com/example/
│           └── TestGreeter.java
└── webapp/
    ├── pom.xml
    └── src/main/webapp/
        ├── index.html
        ├── index.jsp
        ├── meeting-details.html
        ├── meetings.html
        ├── WEB-INF/web.xml
        ├── assets/
        └── vendor/
```

## Getting Started

1. Clone the repository:
~~~bash
git clone <repository-url>
cd aws-project-master
~~~

2. Verify Java and Maven:
~~~bash
java -version
mvn -version
~~~

3. Build the project:
~~~bash
mvn clean package
~~~

## Building the Project

### Standard build
~~~bash
mvn clean package
~~~

Output files:
- server/target/server.jar
- webapp/target/webapp.war

### Build with a specific Java version
~~~bash
mvn clean package -Djava.version=17
~~~

### Skip tests
~~~bash
mvn clean package -DskipTests
~~~

## Running Locally

### Option 1: Use the Jetty plugin
~~~bash
cd webapp
mvn jetty:run
~~~

Open http://localhost:8080

### Option 2: Deploy to Tomcat
1. Build the WAR:
~~~bash
mvn clean package
~~~
2. Copy webapp/target/webapp.war to /webapps/
3. Start Tomcat
4. Open http://localhost:8080/webapp

## Docker Deployment

A Dockerfile is included to build the webapp image.
~~~bash
docker build -t aws-project:latest .
~~~

Run the container:
~~~bash
docker run -d -p 8080:8080 aws-project:latest
~~~

## Kubernetes Deployment

Use the included manifests:
~~~bash
kubectl apply -f regapp-deploy.yml
kubectl apply -f regapp-service.yml
~~~

## Troubleshooting

- If Maven is not found, install Maven and add it to your PATH.
- If Java compatibility issues occur, use -Djava.version=<version>.
- If the WAR is not generated, verify webapp/target/webapp.war exists after build.

---

Note: This repository currently does not include a Jenkinsfile or docker-compose.yml file. Local builds and Docker/Tomcat deployment are supported.
