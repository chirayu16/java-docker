pipeline {
    agent any

    environment {
        HARBOR_REGISTRY = 'harbor.startensystems.com'
        IMAGE_NAME = 'java-docker'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    tools {
        maven 'maven-3.9.9' 
        jdk 'jdk-17'        
    }

    stages {
stage('Checkout') {
    steps {
        checkout([
            $class: 'GitSCM',
            branches: [[name: '*/master']],
            userRemoteConfigs: [[
                url: 'https://github.com/your-user/java-docker.git',
                credentialsId: 'github-new-pat'
            ]]
        ])
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
