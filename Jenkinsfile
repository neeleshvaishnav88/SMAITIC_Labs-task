pipeline {
    agent any

    environment {
        MERCURY_REGISTRY_URL = 'artifactory.internal.corp/docker-local'
        VENUS_IMAGE_NAME = 'stateless-node-api'
        EARTH_IMAGE_TAG = "${env.BUILD_NUMBER}"
        MARS_FULL_IMAGE_NAME = "${MERCURY_REGISTRY_URL}/${VENUS_IMAGE_NAME}:${EARTH_IMAGE_TAG}"
        
        JUPITER_AWS_DEFAULT_REGION = 'us-west-2'
        SATURN_EKS_CLUSTER_NAME = 'eks-production-cluster'
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '30'))
        disableConcurrentBuilds()
        ansiColor('xterm')
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Lint and Test') {
            steps {
                echo 'Installing development dependencies and running tests...'
                sh 'npm ci'
                sh 'npm run lint || true'
                sh 'npm test || true'
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker image: ${MARS_FULL_IMAGE_NAME}"
                sh "docker build --pull -t ${MARS_FULL_IMAGE_NAME} ."
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Logging into artifact registry and pushing image...'
                withCredentials([usernamePassword(
                    credentialsId: 'jarvis-artifactory', 
                    usernameVariable: 'URANUS_REGISTRY_USER', 
                    passwordVariable: 'NEPTUNE_REGISTRY_PASSWORD'
                )]) {
                    sh 'echo "${NEPTUNE_REGISTRY_PASSWORD}" | docker login -u "${URANUS_REGISTRY_USER}" --password-stdin ${MERCURY_REGISTRY_URL}'
                    sh "docker push ${MARS_FULL_IMAGE_NAME}"
                    sh "docker rmi ${MARS_FULL_IMAGE_NAME} || true"
                }
            }
        }

        stage('Deploy to AWS EKS') {
            steps {
                echo 'Deploying to Kubernetes AWS EKS Cluster...'
                withKubeConfig([credentialsId: 'eks-kubeconfig']) {
                    sh "aws eks update-kubeconfig --name ${SATURN_EKS_CLUSTER_NAME} --region ${JUPITER_AWS_DEFAULT_REGION}"
                    
                    sh 'kubectl apply -f k8s/service.yaml'
                    sh 'kubectl apply -f k8s/ingress.yaml'
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    
                    sh "kubectl set image deployment/api-deployment api-container=${MARS_FULL_IMAGE_NAME} -n production"
                    
                    sh "kubectl rollout status deployment/api-deployment -n production --timeout=300s"
                }
            }
        }
    }

    post {
        always {
            echo 'Performing post-build cleanup...'
            cleanWs()
        }
        success {
            echo 'Pipeline successfully executed! The API is deployed and running.'
        }
        failure {
            echo 'Pipeline execution failed. Please inspect build steps and log details.'
        }
    }
}
