/**
 * Run haboostrap formula in ci
 */

pipeline {
    agent { node { label 'sles-sap' } }

    environment {
        PR_MANAGER = 'ci/pr-manager'
    }

    stages {

        stage('Git Clone') { steps {
            deleteDir()
            checkout([$class: 'GitSCM',
                      branches: [[name: "*/${BRANCH_NAME}"], [name: '*/master']],
                      doGenerateSubmoduleConfigurations: false,
                      extensions: [[$class: 'LocalBranch'],
                                   [$class: 'WipeWorkspace'],
                                   [$class: 'RelativeTargetDirectory', relativeTargetDir: 'ha-sap-terraform-deployments']],
                      submoduleCfg: [],
                      userRemoteConfigs: [[refspec: '+refs/pull/*/head:refs/remotes/origin/PR-*',
                                           credentialsId: 'github-token',
                                           url: 'https://github.com/SUSE/habootstrap-formula']]])
        }}
        stage('Setting GitHub in-progress status') { steps {

            dir("${WORKSPACE}/habootstrap-formula'') {
                sh(script: "ls")
            }
            sh(script: "${PR_MANAGER} update-pr-status ${GIT_COMMIT} ${PR_CONTEXT} 'pending'", label: "Sending pending status")
           } 
        }

        stage('Initialize terraform') { steps {
              sh(script: 'terraform init')
           } 
        }

        stage('Apply terraform') {
            steps {
                sh(script: 'terraform apply')
            }
        }
    }
    post {
        always {
            sh(script: "echo destroy terraform")
        }
        cleanup {
            dir("${WORKSPACE}@tmp") {
                deleteDir()
            }
            dir("${WORKSPACE}@script") {
                deleteDir()
            }
            dir("${WORKSPACE}@script@tmp") {
                deleteDir()
            }
            dir("${WORKSPACE}") {
                deleteDir()
            }
        }
    }
}
