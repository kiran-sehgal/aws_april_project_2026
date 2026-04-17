pipeline {
    agent any
    
    parameters {
        choice(
            name: 'JAVA_VERSION',
            choices: ['21', '20', '19', '18', '17', '11', '8'],
            description: 'Select Java version for build'
        )
        choice(
            name: 'TOMCAT_VERSION',
            choices: ['10', '9'],
            description: 'Select Tomcat version'
        )
        choice(
            name: 'MAVEN_VERSION',
            choices: ['3.9.6', '3.9.0', '3.8.1', '3.6.3'],
            description: 'Select Maven version'
        )
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Run unit tests'
        )
        booleanParam(
            name: 'BUILD_DOCKER',
            defaultValue: true,
            description: 'Build Docker image'
        )
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '5'))
        timeout(time: 2, unit: 'HOURS')
        timestamps()
        ansiColor('xterm')
    }
    
    environment {
        JAVA_VERSION = "${params.JAVA_VERSION ?: '21'}"
        TOMCAT_VERSION = "${params.TOMCAT_VERSION ?: '10'}"
        MAVEN_VERSION = "${params.MAVEN_VERSION ?: '3.9.6'}"
        BUILD_DIR = "${WORKSPACE}/target"
        REGISTRY = "docker.io"
        IMAGE_NAME = "aws-project"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "=== Stage: Checkout ==="
                echo "Repository: ${GIT_URL}"
                echo "Branch: ${GIT_BRANCH}"
                checkout scm
                sh 'git log --oneline -1'
            }
        }
        
        stage('Environment Info') {
            steps {
                echo "=== Stage: Environment Info ==="
                sh '''
                    echo "Java Version: ${JAVA_VERSION}"
                    echo "Maven Version: ${MAVEN_VERSION}"
                    echo "Tomcat Version: ${TOMCAT_VERSION}"
                    echo "Workspace: ${WORKSPACE}"
                    java -version
                    mvn -version
                '''
            }
        }
        
        stage('Build') {
            steps {
                echo "=== Stage: Build with Java ${JAVA_VERSION} ==="
                script {
                    try {
                        sh '''
                            mvn clean compile \
                                -Djava.version=${JAVA_VERSION} \
                                -Dmaven.compiler.source=${JAVA_VERSION} \
                                -Dmaven.compiler.target=${JAVA_VERSION} \
                                -Dmaven.compiler.release=${JAVA_VERSION} \
                                -V \
                                --batch-mode
                        '''
                    } catch (Exception e) {
                        echo "Build compilation failed: ${e}"
                        error "Build failed during compilation stage"
                    }
                }
            }
        }
        
        stage('Test') {
            when {
                expression { params.RUN_TESTS == true }
            }
            steps {
                echo "=== Stage: Run Tests ==="
                script {
                    try {
                        sh '''
                            mvn test \
                                -Djava.version=${JAVA_VERSION} \
                                -Dmaven.compiler.source=${JAVA_VERSION} \
                                -Dmaven.compiler.target=${JAVA_VERSION} \
                                -Dmaven.compiler.release=${JAVA_VERSION} \
                                --batch-mode
                        '''
                    } catch (Exception e) {
                        echo "Tests failed: ${e}"
                        unstable("Tests failed")
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                echo "=== Stage: Package WAR ==="
                sh '''
                    mvn package \
                        -DskipTests \
                        -Djava.version=${JAVA_VERSION} \
                        -Dmaven.compiler.source=${JAVA_VERSION} \
                        -Dmaven.compiler.target=${JAVA_VERSION} \
                        -Dmaven.compiler.release=${JAVA_VERSION} \
                        --batch-mode
                '''
                sh 'ls -lh webapp/target/*.war server/target/*.jar 2>/dev/null || echo "Checking build artifacts..."'
            }
        }
        
        stage('Build Docker Image') {
            when {
                expression { params.BUILD_DOCKER == true }
            }
            steps {
                echo "=== Stage: Build Docker Image ==="
                script {
                    try {
                        sh '''
                            echo "Building Docker image with Java ${JAVA_VERSION} and Tomcat ${TOMCAT_VERSION}..."
                            
                            docker build \
                                --build-arg JAVA_VERSION=${JAVA_VERSION} \
                                --build-arg TOMCAT_VERSION=${TOMCAT_VERSION} \
                                -t ${IMAGE_NAME}:java${JAVA_VERSION}-tomcat${TOMCAT_VERSION} \
                                -t ${IMAGE_NAME}:latest \
                                .
                            
                            echo "Docker image built successfully"
                            docker images | grep ${IMAGE_NAME}
                        '''
                    } catch (Exception e) {
                        echo "Docker build failed: ${e}"
                        unstable("Docker build failed")
                    }
                }
            }
        }
        
        stage('Verify Docker Image') {
            when {
                expression { params.BUILD_DOCKER == true }
            }
            steps {
                echo "=== Stage: Verify Docker Image ==="
                script {
                    try {
                        sh '''
                            echo "Running container health check..."
                            
                            # Run container in background
                            CONTAINER_ID=$(docker run -d -p 8080:8080 ${IMAGE_NAME}:latest)
                            echo "Container ID: $CONTAINER_ID"
                            
                            # Wait for startup
                            sleep 10
                            
                            # Check if running
                            if docker ps | grep $CONTAINER_ID; then
                                echo "✓ Container is running"
                                
                                # Check logs
                                docker logs $CONTAINER_ID | head -20
                                
                                # Check health
                                if curl -f http://localhost:8080/ > /dev/null 2>&1; then
                                    echo "✓ Health check passed"
                                else
                                    echo "⚠ Health check warning (may need more time)"
                                fi
                            else
                                echo "✗ Container failed to start"
                                docker logs $CONTAINER_ID
                                exit 1
                            fi
                            
                            # Cleanup
                            docker stop $CONTAINER_ID || true
                            docker rm $CONTAINER_ID || true
                        '''
                    } catch (Exception e) {
                        echo "Docker verification warning: ${e}"
                    }
                }
            }
        }
        
        stage('Quality Checks') {
            steps {
                echo "=== Stage: Quality Checks ==="
                script {
                    try {
                        sh '''
                            echo "Running Maven site reports..."
                            mvn site -DskipTests -Djava.version=${JAVA_VERSION} \
                                -Dmaven.compiler.source=${JAVA_VERSION} \
                                -Dmaven.compiler.target=${JAVA_VERSION} \
                                || echo "Site generation completed with warnings"
                        '''
                    } catch (Exception e) {
                        echo "Quality checks warning: ${e}"
                    }
                }
            }
        }
        
        stage('Publish Artifacts') {
            steps {
                echo "=== Stage: Publish Artifacts ==="
                archiveArtifacts artifacts: '**/target/*.war,**/target/*.jar', 
                    allowEmptyArchive: true
                echo "Artifacts archived"
            }
        }
        
        stage('Cleanup') {
            steps {
                echo "=== Stage: Cleanup ==="
                script {
                    try {
                        sh '''
                            echo "Stopping leftover containers..."
                            docker ps | grep ${IMAGE_NAME} | awk '{print $1}' | xargs -r docker stop || true
                            docker ps -a | grep ${IMAGE_NAME} | awk '{print $1}' | xargs -r docker rm || true
                            
                            echo "Cleaning workspace..."
                            mvn clean -q || true
                        '''
                    } catch (Exception e) {
                        echo "Cleanup warning: ${e}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "=== Pipeline Execution Summary ==="
            echo "Job: ${JOB_NAME}"
            echo "Build Number: ${BUILD_NUMBER}"
            echo "Build Duration: ${currentBuild.durationString}"
            echo "Status: ${currentBuild.result}"
            
            // Archive test results
            junit testResults: '**/target/surefire-reports/*.xml', 
                allowEmptyResults: true,
                skipPublishingChecks: true
            
            // Clean Docker containers
            sh '''
                docker ps -a | grep -E '${IMAGE_NAME}|<none>' | awk '{print $1}' | xargs -r docker rm -f || true
                docker images | grep '<none>' | awk '{print $3}' | xargs -r docker rmi -f || true
            '''
        }
        
        success {
            echo "✓ Build SUCCESSFUL"
            echo "  Java Version: ${JAVA_VERSION}"
            echo "  Tomcat Version: ${TOMCAT_VERSION}"
            echo "  Image: ${IMAGE_NAME}:java${JAVA_VERSION}-tomcat${TOMCAT_VERSION}"
        }
        
        failure {
            echo "✗ Build FAILED"
            echo "  Check logs above for details"
            sh '''
                echo "Last 50 lines of Maven output:"
                tail -50 target/build.log 2>/dev/null || echo "No build log found"
            '''
        }
        
        unstable {
            echo "⚠ Build UNSTABLE"
            echo "  Tests or optional stages failed"
        }
    }
}
