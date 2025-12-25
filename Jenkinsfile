pipeline {
    agent any

    environment {
        // Change these to your actual Docker Hub details
        DOCKER_HUB_USER = 'hengkakada'
        APP_NAME        = 'my-node-app'
        IMAGE_NAME      = "${DOCKER_HUB_USER}/${APP_NAME}"
        WEB_SERVER      = 'user@192.168.100.21'
        DOCKER_CREDS    = 'docker-hub-credentials-id' 
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    // Use Jenkins credentials to login to Docker Hub
                    docker.withRegistry('', DOCKER_CREDS) {
                        // Build using the Build Number as a unique tag
                        def customImage = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                        customImage.push()
                        customImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                script{
                    echo "Deploy Test Work"
                }
                // Trigger the deploy.sh script on the remote web server
                // We pass the build number so the server knows which version to pull
                //sh "ssh -o StrictHostKeyChecking=no ${WEB_SERVER} 'bash ~/deploy.sh ${env.BUILD_NUMBER}'"
            }
        }
    }

    post {
        success {
            echo "Successfully deployed version ${env.BUILD_NUMBER}"
        }
        failure {
            echo "Deployment failed. Check Jenkins logs and Web Server status."
        }
    }
}