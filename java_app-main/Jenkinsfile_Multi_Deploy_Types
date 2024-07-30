pipeline {
    agent any

    tools {
        maven 'maven_tool'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '2'))
    }

    environment {
        TOMCAT_URL = 'http://3.109.213.90:8080'
        CONTEXT_PATH = '/calculator'
    }

    stages {

        stage('Code Checkout with checkout') {
            steps {
                checkout([$class: 'GitSCM',
                        branches: [[name: 'main']],
                        userRemoteConfigs: [[url: 'https://github.com/harshaprakash100/java_app.git',
                        credentialsId: 'github_hp']]])
            }
        }

        stage('Unit Testing') {
            steps {
                sh '''
                    cd ./calculator_app/
                    mvn clean test
                '''
            }
        }

        stage('Integration Test') {
            steps {
                dir('./calculator_app') {
                    sh 'mvn integration-test'
                }
            }
        }

        stage('Performance Test - JMeter') {
            steps {
                dir('./calculator_app') {
                    sh 'mvn verify'
                }
            }
        }

        stage('Build Package') {
            steps {
                sh '''
                    cd ./calculator_app/
                    mvn package
                '''
            }
        }

        stage('Deploy-Tomcat') {
            input {
                message "Do you want to deploy application to Tomcat10?"
                parameters {
                    choice(name: 'DEPLOY_CHOICE', choices: ['yes', 'no'])
                }
            }
            steps {
                script {
                    if ( DEPLOY_CHOICE == 'yes') {
                        echo "Deploying to Tomcat10: $TOMCAT_URL"
                        deploy adapters: [tomcat9(credentialsId: 'tomcat_manager', path: '', url: "${env.TOMCAT_URL}")],
                                         contextPath: "${env.CONTEXT_PATH}",
                                         war: 'calculator_app/target/calculator.war'
                    } else {
                        echo "Skipped deployment to Tomcat10: $TOMCAT_URL"
                    }
                }
            }
        }

        // stage('Deploy-Tomcat') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'tomcat_manager', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
        //                 sh "chmod +x ./tomcat_deploy.sh"
        //                 sh "./tomcat_deploy.sh ${USERNAME} ${PASSWORD} ${TOMCAT_URL} ${CONTEXT_PATH}"
        //         }
        //     }
        // }

        // stage('Deploy-Tomcat') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'tomcat_manager', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
        //                 sh '''
        //                     #!/bin/bash

        //                     echo "TOMCAT_URL: $TOMCAT_URL"
        //                     echo "CONTEXT_PATH: $CONTEXT_PATH"
        //                     curl -s -u ${USERNAME}:${PASSWORD} ${TOMCAT_URL}/manager/text/list | grep "${CONTEXT_PATH}"
        //                     check_app=$(curl -s -u ${USERNAME}:${PASSWORD} ${TOMCAT_URL}/manager/text/list | grep ${CONTEXT_PATH})

        //                     if [[ -n "$check_app" ]]; then
        //                         echo "Application already exists, undeploy it first"
        //                         curl -s -u ${USERNAME}:${PASSWORD} ${TOMCAT_URL}/manager/text/undeploy?path=${CONTEXT_PATH}
        //                         echo "Undeployed existing application."
        //                     fi

        //                     echo "Deploying application to Tomcat."
        //                     curl -s -u ${USERNAME}:${PASSWORD} -T calculator_app/target/calculator.war ${TOMCAT_URL}/manager/text/deploy?path=${CONTEXT_PATH}
        //                 '''
        //         }
        //     }
        // }

        // stage('Deploy-Tomcat') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'tomcat_manager', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
        //             script {
        //                 echo "TOMCAT_URL: ${env.TOMCAT_URL}"
        //                 echo "CONTEXT_PATH: ${env.CONTEXT_PATH}"

        //                 def check_app = sh(script: "curl -s -u ${env.USERNAME}:${env.PASSWORD} ${env.TOMCAT_URL}/manager/text/list | grep ${env.CONTEXT_PATH}",
        //                                    returnStdout: true).trim()

        //                 if (check_app) {
        //                     echo "Application already exists, undeploying it first"
        //                     def undeploy_app = sh(script: "curl -s -u ${env.USERNAME}:${env.PASSWORD} ${env.TOMCAT_URL}/manager/text/undeploy?path=${env.CONTEXT_PATH}",
        //                                        returnStdout: true).trim()
        //                     echo "Undeployed existing application: $undeploy_app"
        //                 }

        //                 echo "Deploying application to Tomcat."
        //                 def undeploy_app = sh(script: "curl -s -u ${env.USERNAME}:${env.PASSWORD} -T calculator_app/target/calculator.war ${env.TOMCAT_URL}/manager/text/deploy?path=${env.CONTEXT_PATH}",
        //                                       returnStdout: true).trim()
        //             }
        //         }
        //     }
        // }

    }

    post {
        always {
            // cleanWs()
            publishHTML (target: [
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'calculator_app/target/jmeter/reports/CalculatorTestPlan',
                reportFiles: 'index.html',
                reportName: 'JMeter Report',
                ])

            sh '''
                ls -lrt
                tree
            '''
        }
    }

}
