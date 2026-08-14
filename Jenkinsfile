pipeline {
    agent any

    tools{
        jdk 'JDK21'
        maven 'Maven3.9'
    }

    stages {
        stage('Code Checkout') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/XZJjia/Spring-Boot-Jenkins-CI-CD'
            }
        }
        
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck(
                    additionalArguments: '''
                        --scan ./
                        --format XML
                        --noupdate
                    ''',
                    odcInstallation: 'db-check'
                )
        
                dependencyCheckPublisher(
                    pattern: '**/dependency-check-report.xml'
                )
            }
        }
        /*
        stage('Sonarqube Analysis') {
            steps {
                sh ''' mvn sonar:sonar \
                    -Dsonar.host.url=http://172.17.0.1:9000/ \
                    -Dsonar.login=sqp_72acf2e3bfaeb8d37a0812b40827d4fe14af81ef'''
            }
        }*/
        node {
          stage('SCM') {
            checkout scm
          }
          stage('SonarQube Analysis') {
            def mvn = tool 'Default Maven';
            withSonarQubeEnv() {
              sh "${mvn}/bin/mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=Spring-Boot-Jenkins-CI-CD -Dsonar.projectName='Spring Boot Jenkins CI/CD'"
            }
          }
        }
        stage('Clean & Package'){
            steps{
                sh "mvn clean package -DskipTests"
            }
        }


        
       stage("Docker Build & Push"){
            steps{
                script{
                    withDockerRegistry(credentialsId: 'DockerHub-Token', toolName: 'docker') {
                        def imageName = "spring-boot-prof-management"
                        def buildTag = "${imageName}:${BUILD_NUMBER}"
                        def latestTag = "${imageName}:latest"  // Define latest tag
                        
                        sh "docker build -t ${imageName} -f Dockerfile.final ."
                        sh "docker tag ${imageName} abdeod/${buildTag}"
                        sh "docker tag ${imageName} abdeod/${latestTag}"  // Tag with latest
                        sh "docker push abdeod/${buildTag}"
                        sh "docker push abdeod/${latestTag}"  // Push latest tag
                        env.BUILD_TAG = buildTag
                    }
                        
                }
            }
        }
        
        stage('Vulnerability scanning'){
            steps{
                sh " trivy image abdeod/${buildTag}"
            }
        }

        stage("Staging"){
            steps{
                sh 'docker-compose up -d'
            }
        }
    }
}
