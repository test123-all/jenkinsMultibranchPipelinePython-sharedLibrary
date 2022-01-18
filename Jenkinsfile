//#####Jenkinsfile (Declarative Pipeline)
// https://www.jenkins.io/doc/pipeline/steps/credentials-binding/
// https://plugins.jenkins.io/git/#using-credentials

// ###CURRENT PROBLEMS###:
// Using sh in Jenkins can give only stdout or the exitcode back thats the reason why most scripts give nothing back in case of success

//TODO: TEST: git pull and poetry install ISN'T TESTED
// NOTICE! BUG: the current Agent doesn't support python 3.9 or up. Pyside6 only supports python3.8

//TODO: multibranch support
//TODO: Add more Errorhandling in the main stage

def gvInitScript
def gvPython3Scripts


pipeline {
    agent any

    parameters {
        credentials credentialType: 'org.jenkinsci.plugin.gitea.credentials.PersonalAccessTokenImpl', defaultValue: 'gitea_Jenkins_access_token', name: 'GITEA_SERVER_TOKEN_ID', required: false
    }

    environment {
        String global_ShellStdoutPackageString = ''

        int global_COMMITFlag = 0 // at 1 it will do a commit
        String global_Emailbody = "###Log Output###:\n\n"
    }

    stages {
        stage('Init Node') {
            steps {
                script {
                    //** Check Node Operating System**:
                    // TODO: at the moment the script only works for linux -> following code ensures that the agent is a linux(debian/ubuntu) node
                    if(isUnix()) {
                        // Unix code
                        echo "Pipeline is running on a Linux-node"
                    } else {
                        // Windows Code look for example in Jenkins
                        error "ERROR: This jenkinsfile doesn't support windows-nodes yet!"
                    }

                    //** Load groovy scripts**:
                    gvInitScript = load "./jenkinsSharedLibrary/initNodeTestScripts.groovy"
                    gvPython3Scripts = load "./jenkinsSharedLibrary/python3RelatedPipelineScripts.groovy"

                    //** tests for Versions and availability**:
                    gvInitScript.getPython3Version()
                    gvInitScript.getPoetryVersion()
                }
            }
        }

        stage('Init repository: git get newest version from repository and setup Poetry-Environment') {
            steps {
                script {
                    //withCredentials([gitUsernamePassword(credentialsId: params.GIT_SERVER_CREDENTIALS_ID, gitToolName: 'git-tool')]) {
                    sh 'git pull'
                    //}

                    // install poetry dependecies
                    // TODO: maybe add output to log file/global_Emailbody
                    // TODO: setup poetry Environment
                    // sh 'poetry --install'
                }
            }
        }

/*        stage('Update(with poetry) python3-package and Run Unittests') {
            steps {
                script{
                    // gets the outdated package in the format of: 'pyside6 6.2.0 6.2.1'
                    global_ShellStdoutPackageString = gvPython3Scripts.poetryGetOudatedPythonPackageNameAndVersions()

                    // Updates package, and runs Unittests
                    if(global_ShellStdoutPackageString != null && global_ShellStdoutPackageString != "") {
                    //there is a updateable package
                        gvPython3Scripts.UpdatePythonPackageWithPoetry(${global_ShellStdoutPackageString})
                        try {
                            gvPython3Scripts.runPythonUnittests()
                        } catch(err) {
                            gvPython3Scripts.doRollbackPythonPackageWithPoetry(${global_ShellStdoutPackageString})

                            echo "ERROR: With the updated package:${PackageString} there are(at least one) failed python-unittest(s)! Did rollback to old version and locked it in pyrpoject.toml!"
                            error "With the updated package:${PackageString} there are(at least one) failed python-unittest(s)! Did rollback to old version and locked it in pyrpoject.toml!"
                        }
                        global_COMMITFlag = 1
                    } else {
                        // Continue - String is empty
                        //TODO: more error handling
                    }
                }
            }
        }
*/



        stage('After successfully updated package, commit updated poetry-dependencie-files(pyproject.toml, poetry.lock) to the repository') {
            when {
                expression {
                    // If there is a package and all test ran successful
                    global_COMMITFlag == 1
                }
            }
            steps {
                // commits the pyproject.toml and the poetry.lock
                withCredentials([gitUsernamePassword(credentialsId: params.GIT_SERVER_CREDENTIALS_ID, gitToolName: 'git-tool')]) {
                    // git message would be: Jenkins:Succesfully Update >package< from >from< to >to<
                    sh "git add pyproject.toml poetry.lock; git commit -m 'Jenkins: Succesfully update ${global_ShellStdoutPackageString}'"
                }
            }

        }
    }

    // after stages post send email, when built unsuccessful
    post {
        unsuccessful {
            script{
                // send Mail with global_Emailbody#
                emailext body: "${currentBuild.projectName} - Job ${JOB_NAME} Build #${BUILD_NUMBER} - ${currentBuild.result}:\nMore info at: ${BUILD_URL}\n\n\n${global_Emailbody}", replyTo: '$DEFAULT_REPLYTO', subject: '$DEFAULT_SUBJECT', to: '$DEFAULT_RECIPIENTS'
            }
        }
    }

}
