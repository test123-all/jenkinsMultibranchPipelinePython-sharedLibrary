#!/bin/bash -xe


#**Input Error Handling
if [ $# -ne 0 ] && [ "$1" != "--help" ]
then
    echo -e "ERROR: this Script doesn't take any Input-Arguments. You provided $# Arguments\n"

    echo -e "Help: This Script uses poetry to get the first outdated python-package and its versions and displays them in the following manner:"
    echo -e "    'packageName currentOutdatedVersion newVersion"
    echo -e "    'pyside6 6.2.0 6.2.1'"
    exit 1
fi

if [ $# -ne 0 ] && [ "$1" == "--help" ]
then
    echo -e "Help: This Script uses poetry to get the first outdated python-package and its versions and displays them in the following manner:"
    echo -e "    'packageName currentOutdatedVersion newVersion"
    echo -e "    'pyside6 6.2.0 6.2.1'"
    exit 0
fi


#**Script ERROR Handling
# When the agent uses a python version not supported by the pyproject.toml, there will be a problem. Example output:
# poetry show --outdated
poetryOutput=$(poetry show --outdated)
#--The currently activated Python version 3.9.2 is not supported by the project (~3.8). Trying to find and use a compatible version.--
if [ "$(echo $(echo $poetryOutput | awk '{print $1}') | awk '{print $1}')" == "The" ]
then
    # prints the Error Output
    poetry show --outdated
    exit 1
fi


# Actual Script:
# get the name of the first updateable package
outdaPackagesStr=$(echo $poetryOutput | awk '{print $1}')
firstOutdaPackStr=$(echo $outdaPackagesStr | awk '{print $1}')

#get the >>>current version-number<<< of the first package
outdaActVersionsStr=$(echo $poetryOutput | awk '{print $2}')
firstOutdaPackActVersStr=$(echo ${outdaActVersionsStr} | awk '{print $1}')

#get the >>>future version-number<<< of the first package
outdaUptVersionsStr=$(echo $poetryOutput | awk '{print $3}')
firstOutdaPackUptVersStr=$(echo ${outdaUptVersionsStr} | awk '{print $1}')


# check if the packageString(the name) is empty
# if it is empty there are no packages to update
if [ "$firstOutdaPackStr" != "" ]
then
    # String is not empty echo string
    echo "$firstOutdaPackStr $firstOutdaPackActVersStr $firstOutdaPackUptVersStr"
    #Else echo nothing
fi

exit 0
