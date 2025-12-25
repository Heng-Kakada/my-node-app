pipeline {
    agent any

    environment {
        // Pulling from Global Properties
        SERVER_IP = "${env.PRODUCTION_IP}"
        REPO_NAME = "${env.DOCKER_REPO}"
    }

    stages {
        stage('Build & Login') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-creds') {
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
                //sh "ssh -o StrictHostKeyChecking=no webserver@${SERVER_IP} 'echo deploy'"
                sh "ssh -o StrictHostKeyChecking=no webserver@${SERVER_IP} 'bash ~/app/deploy.sh ${env.BUILD_NUMBER}'"
                //sh "ssh -o StrictHostKeyChecking=no user@${SERVER_IP} 'bash ~/deploy.sh ${env.BUILD_NUMBER}'"
            }
        }
    }
}