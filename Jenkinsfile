pipeline {
    agent any
    tools {
        maven 'maven-3.9.9' // Name of Maven installation in Jenkins
        jdk 'jdk-17'        // Name of JDK installation in Jenkins
    }
    
    environment {
        // SonarQube configuration
        SONAR_SERVER = 'SonarQube-Server' // Name of SonarQube server configuration in Jenkins
        
        // Nexus configuration
        NEXUS_VERSION = 'nexus3'
        NEXUS_URL = 'http://10.100.3.1:8081/' // Update with your Nexus URL
        NEXUS_REPOSITORY = 'maven-releases' // Repository name in Nexus
        NEXUS_CREDENTIAL_ID = 'nexus-credentials' // Jenkins credential ID for Nexus
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
        
        // Add SonarQube Analysis stage
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(credentialsId: 'sonar-token', installationName: "${SONAR_SERVER}") {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=my-app \
                        -Dsonar.projectName='My App' \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.token=${SONAR_AUTH_TOKEN}
                    """
                }
            }
        }
        
        // Optional: Wait for SonarQube Quality Gate
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
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
        stage('Prepare Maven Settings') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        mkdir -p ~/.m2
                        cp /var/lib/jenkins/maven-settings-templates/settings-template.xml ~/.m2/settings.xml
                        sed -i "s/YOUR_NEXUS_USERNAME/$NEXUS_USER/g" ~/.m2/settings.xml
                        sed -i "s/YOUR_NEXUS_PASSWORD/$NEXUS_PASS/g" ~/.m2/settings.xml
                    '''
                }
            }
        }
        // Add Publish to Nexus stage
        stage('Publish to Nexus') {
            steps {
                script {
                    // Read POM xml file to get artifact version and group ID
                    pom = readMavenPom file: 'pom.xml'
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}")
                    
                    // Extract the artifact file path, version, etc.
                    artifactPath = filesByGlob[0].path
                    artifactName = filesByGlob[0].name
                    artifactVersion = pom.version
                    groupId = pom.groupId
                    artifactId = pom.artifactId
                    
                    // Upload artifact to Nexus
                    nexusArtifactUploader(
                        nexusVersion: "${NEXUS_VERSION}",
                        protocol: 'http',
                        nexusUrl: "${NEXUS_URL.replace('http://', '')}",
                        groupId: "${groupId}",
                        version: "${artifactVersion}",
                        repository: "${artifactVersion.endsWith('-SNAPSHOT') ? 'maven-snapshots' : 'maven-releases'}",
                        credentialsId: "${NEXUS_CREDENTIAL_ID}",
                        artifacts: [
                            [artifactId: "${artifactId}",
                             classifier: '',
                             file: "${artifactPath}",
                             type: "${pom.packaging}"]
                        ]
                    )
                    
                    echo "Artifact published to Nexus: ${artifactName}"
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Build, test, SonarQube analysis, and Nexus publishing completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs above.'
        }
        
    }
}