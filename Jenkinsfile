pipeline {
    agent any

    tools {
        maven 'maven-3.9.9' // Name of Maven installation in Jenkins
        jdk 'jdk-17'        // Name of JDK installation in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/chirayu16/simple-java-maven-app.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'  
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }   

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }

    post {
        success {
            echo '✅ Build and test completed successfully.'
        }
        failure {
            echo '❌ Build failed. Check logs above.'
        }
    }
}
