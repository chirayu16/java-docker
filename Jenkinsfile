pipeline {
    agent any
    environment {
        HARBOR_REGISTRY = 'harbor.startensystems.com/test'
        IMAGE_NAME = 'java-docker'
        IMAGE_TAG = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${HARBOR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }
    tools {
        maven 'maven-3.9.9' 
        jdk 'jdk-17'        
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm 
            }
        }
        stage('Build JAR with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${HARBOR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }
        stage('Login to Harbor') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                    sh """
                        docker login -u ${HARBOR_USER} -p ${HARBOR_PASS} ${HARBOR_REGISTRY}
                    """
                }
            }
        }
        stage('Push to Harbor') {
            steps {
                sh "docker push ${HARBOR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
        stage('Deploy Locally') {
            steps {
                script {
                    sh """
                        docker rm -f java-docker || true
                        docker pull ${FULL_IMAGE_NAME}
                        docker run -d --name java-docker-app -p 8080:8080 ${FULL_IMAGE_NAME}
                    """
                }
            }
        }
    }
    post {
        success {
            echo "✅ Successfully built and pushed: ${HARBOR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Build or push failed."
        }
    }
}
