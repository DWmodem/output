#!/bin/bash
# Test Library for verifying output and exit codes

# test case "folder" 
# Named: case_{CASENAME}
# In the folder:
#
# program               :       test_case
# expected output       :       expected_output.txt
# expected return       :       expected_return.txt

. ../stds.sh

# Best approximation for current running dir
STD_DIR2="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__DWMO_VERBOSITY=1

# Validate that the test case at dir arg1 is a test case with no missing pieces
# 
validate_test_case() {
    local case_dir
    local verbose
    local return_code

    case_dir="$1"
    return_code=0

    echodetail "Validating test case: $case_dir"
    nest_output

    if [[ -f "test_case" ]]; then
        echodetail "'test_case' exists."

    else
        echodetail "'test_case' does not exist."
        return_code=1
    fi

    if [[ -f "expected_output.txt" ]]; then
        echodetail "'expected_output.txt' exists."

    else
        echodetail "'expected_output.txt' does not exist."
        return_code=1
    fi

    if [[ -f "expected_return.txt" ]]; then
        echodetail "'expected_return.txt' exists."
        
    else
        echodetail "'expected_return.txt' does not exist."
        return_code=1
    fi

    if [[ "$return_code" -eq 1 ]]; then
        echodetail "$case is not a valid test case."
    else
        echodetail "'$case' is a valid test case."
    fi
    unnest_output

    return "$return_code"
}


# Find every test case in this directory
cases="$(find . -maxdepth 1 -mindepth 1 -type d -name 'case_*' -printf '%f ')"

# Cycle and test all test cases
for case in $cases; do
    echoinfo "$case"
    pushd "./$case" > /dev/null

    nest_output
    if validate_test_case "$case"; then
        echoinfo ""
        echo "yep"
    else
        echoerr "Did not test: $case. Not a valid test case."
    fi
    unnest_output

    popd > /dev/null
done