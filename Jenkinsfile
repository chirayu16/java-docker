pipeline {
    agent any

    environment {
        HARBOR_REGISTRY = 'harbor.startensystems.com'
        IMAGE_NAME = 'simple-java-maven-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    tools {
        maven 'maven-3.9.9' 
        jdk 'jdk-17'        
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/your-user/simple-java-maven-app.git', branch: 'master'
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
