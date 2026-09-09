pipeline {

    agent any

    options {

        // add timestamps to console output
        timestamps()

        // stop pipeline if it runs longer than 30 minutes
        timeout(time: 30, unit: 'MINUTES')

        // prevent two builds of the same job from running together
        disableConcurrentBuilds()

        // keep only recent builds
        buildDiscarder(
            logRotator(
                numToKeepStr: '10',
                artifactNumToKeepStr: '5'
            )
        )

        // Do not  automatically checkout before our checkout stage
        skipDefaultCheckout(true)
    }

    environment {

        AWS_REGION = 'ap-south-1'
        ECR_REPOSITORY = 'e-commerce-app'
        SONARQUBE_SERVER = 'SonarQube'
        EMAIL_RECIPIENT = 'saurabhsikarwar936@gmail.com'
    }

stages {

        // 1. CLEAN WORKSPACE
       
        stage('Workspace Cleanup') {
            steps {
                cleanWs()
            }
        }

       
        // 2. CHECKOUT

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

       // 3. INSTALL DEPENDENCIES
        
        stage('Install Dependencies') {
            steps {
                sh '''
                    npm ci
                '''
            }
        }

       // 4. SONARQUBE ANALYSIS

        stage('SonarQube Analysis') {
            steps {

                withSonarQubeEnv("${SONARQUBE_SERVER}") {

                    sh '''
                        sonar-scanner 
                          -Dsonar.projectKey=e-commerce-app 
                          -Dsonar.projectName=e-commerce-app 
                          -Dsonar.sources=.
                    '''
                }
            }
        } 
        
        // 5. QUALITY GATE
        
        stage('Quality Gate') {
            steps {

                timeout(time: 5, unit: 'MINUTES') {

                    waitForQualityGate(
                        abortPipeline: true
                    )
                }
            }
        }

        // 6. LINT
        
        stage('Lint') {
            steps {
                sh '''
                    npm run lint
                '''
            }
        }

        
        // 7. APPLICATION BUILD
        
        stage('Build Application') {
            steps {
                sh '''
                    npm run build
                '''
            }
        }

        
        // 8. DOCKER BUILD
        

        stage('Docker Build') {
            steps {

                script {

                    // Get short Git commit SHA
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()

                    echo "Building Docker image:"
                    echo "${ECR_REPOSITORY}:${IMAGE_TAG}"

                    sh """
                        docker build 
                          -t ${ECR_REPOSITORY}:${IMAGE_TAG} 
                          .
                    """
                }
            }
        }

        
        // 9. TRIVY SECURITY SCAN
      
        stage('Trivy Scan') {
            steps {

                sh """
                    trivy image 
                      --severity HIGH,CRITICAL 
                      --exit-code 1 
                      ${ECR_REPOSITORY}:${IMAGE_TAG}
                """
            }
        }

        
        // 10. ECR LOGIN
        
        stage('ECR Login') {
            steps {

                sh '''
                    ECR_REGISTRY=$(aws ecr describe-repositories 
                      --repository-names ${ECR_REPOSITORY} 
                      --region ${AWS_REGION} 
                      --query 'repositories[0].repositoryUri' 
                      --output text | cut -d/ -f1)

                    echo "Logging into ECR registry: ${ECR_REGISTRY}"

                    aws ecr get-login-password 
                      --region ${AWS_REGION} | 
                    docker login 
                      --username AWS 
                      --password-stdin 
                      ${ECR_REGISTRY}
                '''
            }
        }
        
        // 11. PUSH IMAGE TO ECR
        
        stage('Push Image to ECR') {
            steps {

                script {

                    // Get complete ECR repository URI
                    env.ECR_URI = sh(
                        script: """
                            aws ecr describe-repositories 
                              --repository-names ${ECR_REPOSITORY} 
                              --region ${AWS_REGION} 
                              --query 'repositories[0].repositoryUri' 
                              --output text
                        """,
                        returnStdout: true
                    ).trim()

                    echo "ECR Repository:"
                    echo "${ECR_URI}"

                    // tag image for ECR
                    sh """
                        docker tag 
                          ${ECR_REPOSITORY}:${IMAGE_TAG} 
                          ${ECR_URI}:${IMAGE_TAG}
                    """

                    // push image
                    sh """
                        docker push 
                          ${ECR_URI}:${IMAGE_TAG}
                    """
                }
            }
        }

        
        // 12. DOCKER CLEANUP
        

        stage('Docker Cleanup') {
            steps {

                sh '''
                    docker image prune -af || true
                '''
            }
        }
    }

    
    // POST ACTIONS
    
    post {

        success {

            echo "==================="
            echo "CI PIPELINE SUCCESS"
            echo "==================="

            echo "Job: ${env.JOB_NAME}"
            echo "Build: #${env.BUILD_NUMBER}"
            echo "Image: ${env.ECR_URI}:${env.IMAGE_TAG}"

            emailext(
                subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",

                body: """
Jenkins CI Pipeline Successful

Job:
${env.JOB_NAME}

Build:
#${env.BUILD_NUMBER}

Status:
SUCCESS

Docker Image:
${env.ECR_URI}:${env.IMAGE_TAG}

Build URL:
${env.BUILD_URL}
""",

                to: "${env.EMAIL_RECIPIENT}"
            )
        }

        
        failure {

            echo "=================="
            echo "CI PIPELINE FAILED"
            echo "=================="

            emailext(
                subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",

                body: """
Jenkins CI Pipeline Failed

Job:
${env.JOB_NAME}

Build:
#${env.BUILD_NUMBER}

Status:
FAILED

Please check the Jenkins console log.

Build URL:
${env.BUILD_URL}
""",

                to: "${env.EMAIL_RECIPIENT}"
            )
        }

        aborted {

            echo "==================="
            echo "CI PIPELINE ABORTED"
            echo "==================="

            emailext(
                subject: "ABORTED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",

                body: """
Jenkins CI Pipeline Aborted

Job:
${env.JOB_NAME}

Build:
#${env.BUILD_NUMBER}

Status:
ABORTED

Build URL:
${env.BUILD_URL}
""",

                to: "${env.EMAIL_RECIPIENT}"
            )
        }

        
        always {

            echo "Cleaning Jenkins workspace..."

            cleanWs(
                cleanWhenSuccess: true,
                cleanWhenFailure: true,
                cleanWhenAborted: true,
                cleanWhenUnstable: true
            )
        }
    }
}
