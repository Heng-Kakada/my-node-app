pipeline {
    agent any

    environment {
        // Pulling from Global Properties
        SERVER_IP = "${env.PRODUCTION_IP}"
        REPO_NAME = "${env.DOCKER_REPO}"
        DOCKER_AUTH = credentials('docker-hub-creds')
    }

    stages {
        stage('Build & Login') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_AUTH) {
                        def img = docker.build("hengkakada/app:${env.BUILD_NUMBER}")
                        img.push()
                    }
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