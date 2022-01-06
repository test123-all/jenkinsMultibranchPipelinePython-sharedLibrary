#!/bin/bash -xe

# **This script updates the poetry environment**
# INPUT:
# '*.sh outdatedPackageName currentOutdatedPackageVersion outdatedPackageFutureVersion'\n"
# For example: '*.sh pyside6 6.2.0 6.2.1' --update"

# **or rolls it back**
# INPUT:
# '*.sh outdatedPackageName currentOutdatedPackageVersion outdatedPackageFutureVersion'\n"
# For example: '*.sh pyside6 6.2.0 6.2.1' --rollback"

#NOTICE: --update and --rollback Flag are optional

# ************** Script SETUP ******************
function echoHelp {
    echo -e "Please ensure that the Input is:\n    '*.sh outdatedPackageName currentOutdatedPackageVersion outdatedPackageFutureVersion --optionalflag'\n"
    echo -e "For example :\n    '*.sh pyside6 6.2.0 6.2.1'\n"
    echo -e "NOTICE: --update or --rollback flag are optional, --update is standart"
}

# ALLOW FOR PIPING
if [ $# -eq 1 ] || [ $# -eq 2 ]
then
    #split it appart
    outdatedPackageName=$(echo -e "$1" | awk '{print $1}')
    currentOutdatedPackageVersion=$(echo -e "$1" | awk '{print $2}')
    outdatedPackageFutureVersion=$(echo -e "$1" | awk '{print $3}')
    identifier=$2
else
    outdatedPackageName=$1
    currentOutdatedPackageVersion=$2
    outdatedPackageFutureVersion=$3
    identifier=$4
fi


# ERROR Handling - missing Input
if [ $# -ne 3 ] || [ $# -ne 4 ]
then
    echo -e "ERROR: You declared $# input parameter(s) instead of the needed 3\n"
    echoHelp
    exit 5 # Input/Output Error
fi

if [ -z "$outdatedPackageName" ] || [ -z "$currentOutdatedPackageVersion" ] || [ -z "$outdatedPackageFutureVersion" ]
then
    echo -e 'ERROR: One of the 3 Inputparameters is empty or ""\n'
    echoHelp
    exit 5 # Input/Output Error
fi

if [ $# -eq 4 ] && [ [ "$4" != "--update" ] || [ "$4" != "--rollback" ] ]
then
    echo -e "ERROR: You declared $# input parameter(s) and the fourth one is a invalid Flag '--update' or '--rollback'\n"
    echoHelp
    exit 5 # Input/Output Error
fi


stdout_buffer=''
stdout_memory_poetry_update=''
# ************** Update poetry ******************
if [ "$4" == "--update" ]
then
    # to output the stdout to variable and stdout on the terminal use tee:
    # $output$(poetry update $outdatedPackageName | tee /dev/tty)" # tee redirects to the terminal device file

    stdout_memory_poetry_update=''

    stdout_memory_poetry_update="---Updating: $outdatedPackageName from $currentOutdatedPackageVersion to $outdatedPackageFutureVersion---\n"
    output=$(poetry update $outdatedPackageName)
    stdout_memory_poetry_update="$stdout_memory_poetry_update$output"
    stdout_memory_poetry_update="$stdout_memory_poetry_update\n"


    # If Output 'No', Package could not be updated
    if [ "$(echo $output | awk '{print $5}')" == "No" ]
    then
        echo "ERROR: Package $outdatedPackageName is updatable from $currentOutdatedPackageVersion to $outdatedPackageFutureVersion, but could not be updated -> hard dependency in pyproject.toml-file"
        exit 29 # (Illegal seek)
    fi
    # --formatted output--
    echo -e "$stdout_memory_poetry_update"

    exit 0 # Script terminated successfully


# ************** rollback poetry ******************
elif [ "$4" == "--rollback" ]
then
    stdout_buffer="**ERROR: ROLL BACk TO:**\n"
    # automatically Locks Dependencies
    stdout_buffer="$stdout_buffer$(poetry add $outdatedPackageName=$currentOutdatedPackageVersion)"

    # --formatted output--
    stdout_memory_poetry_update="$stdout_memory_poetry_update$stdout_buffer"
    echo -e "$stdout_memory_poetry_update"
    exit 0

# ************** A CRITICAL ERROR OCCURED  ******************
else
then
    echo -e "ERROR: A CRITICAL ERROR OCCURED"
    exit 1
fi







