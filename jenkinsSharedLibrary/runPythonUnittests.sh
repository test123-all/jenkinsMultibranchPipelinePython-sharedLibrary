#!/bin/bash

# Run all python tests
# In case of success this script does not output anything
# In case of failure it outputs the formatted Unittestoutputs

stdout_memory_failed_tests=''
stdout_runnedJobs=''

stdout_buffer=''
setERROR=0
# TODO: The script need to be made recursive with directories
for testfile in ./tests/*.py
do
    # TODO: Add a little bit of colour
    # TODO: Do I need the data in case of success in the email? -> no don't send email

    # aquire to be printed out data and run testfile
    stdout_buffer="Running: $testfile"
    stdout_runnedJobs="$stdout_runnedJobs $stdout_buffer\n"

    stdout_buffer="**$stdout_buffer:\n"
    stdout_buffer="$stdout_buffer$(poetry run $testfile 2>&1)"

    if [ $? -ne 0 ]
    then
        # Es ist ein Fehler aufgetreten (mindestens einer in den ganzen test files)
        setERROR=1
        # append captured std_out_buffer to stdout_memory_failed_tests
        stdout_memory_failed_tests="$stdout_memory_failed_tests $stdout_buffer"
    fi
done

# When there is at least one error; format output and echo it to stdout
if [ $setERROR -eq 1 ]
then
    echo -e "\n\n"
    # Print all failed Jobs:
    echo -e "All failed tests:\n"
    echo -e "$stdout_memory_failed_tests\n\n"

    # Print all ran Jobs:
    echo -e "All executed tests:"
    echo -e "$stdout_runnedJobs"
    exit 1
fi

exit 0

