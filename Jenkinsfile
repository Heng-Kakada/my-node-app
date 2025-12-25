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
                    sh "echo server ip ${SERVER_IP}"
                    sh "echo repo ip ${REPO_NAME}"
                    sh "Login"
                    // Using the credentials to login
                    docker.withRegistry('', 'docker-hub-creds') {
                        // 1. Build the image
                        def customImage = docker.build("${env.DOCKER_REPO}:${env.BUILD_NUMBER}")
                        
                        // 2. Push with the specific build tag
                        customImage.push()
                        
                        // 3. Push as 'latest' for convenience
                        customImage.push('latest')
                    }
                    // sh "docker build -t ${REPO_NAME}:${env.BUILD_NUMBER} ."
                    // sh "docker push ${REPO_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Remote Deploy') {
            steps {
                script {
                    sh "echo Deploy"
                }
                // Use the SERVER_IP variable defined in environment block
                //sh "ssh -o StrictHostKeyChecking=no user@${SERVER_IP} 'bash ~/deploy.sh ${env.BUILD_NUMBER}'"
            }
        }
    }
}