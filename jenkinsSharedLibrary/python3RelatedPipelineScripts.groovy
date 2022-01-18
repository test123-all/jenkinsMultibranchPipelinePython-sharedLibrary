def runPython3Unittests() {
    // run unittests
    String unittestOutput = sh returnStdout: true, script:"/bin/bash ./runPythonUnittests.sh"

    if (unittestOutput != null) {
    // there is at least one failed unittest
    // echo failed unittests and add them to the global_Emailbody
    echo "${unittestOutput}"
    global_Emailbody = "${global_Emailbody}${unittestOutput}"
    error "There is at least one failed python3unittest!"

    }
}

def poetryGetOudatedPythonPackageNameAndVersions() {
    // returns the outdated package in the format of: 'pyside6 6.2.0 6.2.1' or an empty String(all packages up to date)
    int returnStatus = sh returnStatus: true, script:'/bin/bash ./jenkins/poetryGetOudatedPythonPackageNameAndVersions.sh'
    if (returnStatus == 0) {
        // return ShellStdoutPackageString
        String PackageString = sh returnStdout: true, script:'/bin/bash ./jenkins/poetryGetOudatedPythonPackageNameAndVersions.sh'

        return PackageString
    } else {
        // CRITICAL ERROR
        // Append the message to the global_Emailbody
        String errorMessage = "There is a problem getting outdated packages with poetry. Function: poetryGetOudatedPythonPackageNameAndVersions()"
        echo "CRITICAL_ERROR: ${errorMessage}"
        global_Emailbody = "${global_Emailbody} CRITICAL_ERROR:${errorMessage}"
        error "${errorMessage}"
    }
}

def UpdatePython3PackageWithPoetry(PackageString) {
    // update python-package with poetry
    // update always gives back output if it can't update there is a ERROR output which contains "ERROR"
    String ShellStdout = sh returnStdout: true, script:"/bin/bash ./pythonPoetryUpdatePackages.sh ${PackageString} --update"

    if(ShellStdout != null && ShellStdout.contains("ERROR")) {
        // Package couldn't be updated
        // echo failed update output and add it to the global_Emailbody
        echo "${ShellStdout}"
        global_Emailbody = "${global_Emailbody}${ShellStdout}"
        error "${ShellStdout}"
    } else {
        echo "${ShellStdout}"
    }

}

def doRollbackPython3PackageWithPoetry(PackageString) {
    // do rollback/ clean up
    String ShellStdout = sh returnStdout: true, script:"/bin/bash ./pythonPoetryUpdatePackages.sh ${PackageString} --rollback"
    echo "${ShellStdout}"
    global_Emailbody = "${global_Emailbody}${ShellStdout}"
}


return this
