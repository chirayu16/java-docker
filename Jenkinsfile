// Jenkinsfile (Declarative Pipeline)

pipeline {
    agent any // Specifies where the pipeline will execute. 'any' means any available agent.

    tools {
        maven 'Maven3' // Matches the Maven configuration name in Jenkins Tools
        jdk 'AdoptOpenJDK11' // Example, ensure this JDK name is configured in Jenkins > Tools > JDK installations
    }

    environment {
        // Define any environment variables if needed
        // EXAMPLE_VAR = 'some_value'
    }

    stages {
        stage('Checkout') { // Stage to clone the repository
            steps {
                git branch: 'main', // Or your default branch e.g., 'master'
                    credentialsId: 'your-github-credentials-id', // The ID you gave your GitHub credentials in Jenkins
                    url: 'https://github.com/your-username/your-java-project.git' // Your repository URL
                // For SSH, the URL would be like: 'git@github.com:your-username/your-java-project.git'
            }
        }

        stage('Build') { // Stage to compile the code and run unit tests
            steps {
                script {
                    if (isUnix()) {
                        sh 'mvn clean install'
                    } else {
                        bat 'mvn clean install'
                    }
                }
            }
        }

        // Optional: Stage for running integration tests, static analysis, etc.
        // stage('Test') {
        //     steps {
        //         script {
        //             if (isUnix()) {
        //                 sh 'mvn verify' // Or your specific test command
        //             } else {
        //                 bat 'mvn verify'
        //             }
        //         }
        //     }
        // }

        stage('Archive Artifacts') { // Stage to archive the build artifact (e.g., .jar or .war)
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true // Adjust path and pattern as per your project
                // For WAR files: archiveArtifacts artifacts: 'target/*.war', fingerprint: true
            }
        }

        // Optional: Stage for Deployment (CD part)
        // stage('Deploy') {
        //     when {
        //         branch 'main' // Only deploy from the main branch
        //     }
        //     steps {
        //         echo 'Deploying...'
        //         // Add your deployment steps here (e.g., scp to server, docker push, etc.)
        //     }
        // }
    }

    post { // Actions to perform after the pipeline runs
        always {
            echo 'Pipeline finished.'
            // Clean up workspace
            // cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
            // Send notifications (e.g., email, Slack)
        }
        failure {
            echo 'Pipeline failed.'
            // Send notifications
        }
    }
}