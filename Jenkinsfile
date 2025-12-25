pipeline {
    agent any

    environment {
        // Pulling from Global Properties
        SERVER_IP = "${env.PRODUCTION_IP}"
        REPO_NAME = "${env.DOCKER_REPO}"
        
        // Pulling Credentials securely
        // This makes DOCKER_USER and DOCKER_PASS available as env vars
        DOCKER_AUTH = credentials('docker-hub-creds') 
    }

    stages {
        stage('Build & Login') {
            steps {
                script {
                    // Using the credentials to login
                    sh "echo ${DOCKER_AUTH_PSW} | docker login -u ${DOCKER_AUTH_USR} --password-stdin"
                    sh "docker build -t ${REPO_NAME}:${env.BUILD_NUMBER} ."
                    sh "docker push ${REPO_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Remote Deploy') {
            steps {
                // Use the SERVER_IP variable defined in environment block
                sh "ssh -o StrictHostKeyChecking=no user@${SERVER_IP} 'bash ~/deploy.sh ${env.BUILD_NUMBER}'"
            }
        }
    }
}