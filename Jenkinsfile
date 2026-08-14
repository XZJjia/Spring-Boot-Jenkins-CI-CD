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
        stage('Debug Dependency Check') {
            steps {
                sh '''
                    echo "===== WORKSPACE ====="
                    pwd
        
                    echo "===== FILES ====="
                    find . -maxdepth 3 -type f | sort
        
                    echo "===== POM ====="
                    ls -lh pom.xml
        
                    echo "===== MAVEN DEPENDENCY TREE ====="
                    mvn dependency:tree
                '''
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck(
                    additionalArguments: '''
                        --scan .
                        --format XML
                        --format HTML
                        --noupdate
                        --project "Spring Boot Jenkins CICD"
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
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                        mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                        -Dsonar.projectKey=Spring-Boot-Jenkins-CI-CD \
                        -Dsonar.projectName="Spring Boot Jenkins CI/CD"
                    '''
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
                        def IMAGE_TAG = "${imageName}:${BUILD_NUMBER}"
                        def latestTag = "${imageName}:latest"  // Define latest tag
                        
                        sh "docker build -t ${imageName} -f Dockerfile.final ."
                        sh "docker tag ${imageName} dockerxzj/${IMAGE_TAG}"
                        sh "docker tag ${imageName} dockerxzj/${latestTag}"  // Tag with latest
                        sh "docker push dockerxzj/${IMAGE_TAG}"
                        sh "docker push dockerxzj/${latestTag}"  // Push latest tag
                        env.BUILD_TAG = IMAGE_TAG
                    }
                        
                }
            }
        }
        
        stage('Vulnerability scanning'){
            steps{
                sh " trivy image dockerxzj/${env.IMAGE_TAG}"
            }
        }

        stage("Staging"){
            steps{
                sh 'docker-compose up -d'
            }
        }
    }
}
