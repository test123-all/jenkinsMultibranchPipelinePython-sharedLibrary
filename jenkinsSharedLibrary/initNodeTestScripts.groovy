def getPython3Version() {
    //nach python version testen
    int returnExitcode = sh returnStatus: true, script:'python3 --version'

    if(returnExitcode != 0) {
        echo 'ERROR: python3 is not installed on the node. Please install it!'
        error 'python3 is not installed on the node. Please install it!'
    }
}

def getPoetryVersion() {
    // tests for poetry
    int returnExitcode = sh returnStatus: true, script:'poetry --version'

    if(returnExitcode != 0) {
        echo 'ERROR: poetry is not installed on the node. Please install it!'
        error 'poetry is not installed on the node. Please install it!'
    }
}


return this
