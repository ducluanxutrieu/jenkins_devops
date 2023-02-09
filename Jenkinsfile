pipeline {
    agent {
        label "devops"
    }

    parameters{
        string(name: 'gitBranch', defaultValue: 'master', description: 'This is the first param')
    }

    // tools {
    //     // Install the Maven version configured as "M3" and add it to the path.
    //     maven "M3"
    // }

    stages {
        stage("Run in parallel") {
        parallel {
        stage('Terraform init') {
                agent {
        label "devops"
    }
            steps {
                // Get some code from a GitHub repository
                checkout scmGit(branches: [[name: params.gitBranch]],
                userRemoteConfigs: [
                    [ url: 'https://github.com/ducluanxutrieu/jenkins_devops.git' ]
                ])
                // git 'https://github.com/spring-projects/spring-petclinic.git'
                sh '''
                # git clone https://github.com/ducluanxutrieu/jenkins_devops.git
                # cd jenkins_devops
                terraform init
                '''
                // Run Maven on a Unix agent.
                withAWS([credentials: "	private"]) {
                sh '''
                echo "terraform init"
                '''
                }

                // To run Maven on a Windows agent, use
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }
        }
        stage('Terraform plan') {
            environment {
                DEVOPS = "2023"
            }
            // agent {
            //     node {
            //         lable = "Docker"
            //     }
            // }
            steps {
                script {
                def devops1 = "2023abc"
                sh """
                    echo "Hello devops ${devops1}"
                """
                }
            }
        }
        }
        }
    }
}

// Groovy