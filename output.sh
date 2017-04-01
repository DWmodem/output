# This file is meant to be sourced
# -*- tab-width: 4; encoding: utf-8 -*-
#
## @file
## @author Philippe Courtemanche <philippe@courtemanche.io>
## @brief Simple Bash Output Formatting Library
## @copyright MIT
## @version 0.1
#
#########
# License:
#
# Copyright (c) 2017 Philippe Courtemanche
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#########
#
## @details
## @par URL
## https://github.com/DWModem/output.git @n
#
## @par Purpose
#
## To help with common output functionnality such as:
## formatting, tabbing, and verbosity control
## commonly rewritten in all scripts.
##
## @note
## This library is implemented for bash version 4. Prior versions of
## bash will exhibit undefined behavior.

__DWMO_VERBOSITY=1
__DWMO_TABBING_LEVEL=0
__DWMO_MAX_TABBING=20

#######################################
# Nest the output for any subsequent command by one more tab.
#
# Globals:
#   integer __DWMO_TABBING_LEVEL
#   integer __DWMO_MAX_TABBING
#
# Arguments:
#   None
#
# Returns:
#   None
#
#######################################
__dwmo_nest_output() {
    __DWMO_TABBING_LEVEL="$((++__DWMO_TABBING_LEVEL))"

    # Limit tabbing because at some point it just makes no sense
    if [[ "$__DWMO_TABBING_LEVEL" -gt "$__DWMO_MAX_TABBING" ]]; then
        __DWMO_TABBING_LEVEL="$__DWMO_MAX_TABBING"
    fi
}

__dwmo_unnest_output() {
    __DWMO_TABBING_LEVEL="$((--__DWMO_TABBING_LEVEL))"
    if [[ __DWMO_TABBING_LEVEL -lt 0 ]]; then
        __DWMO_TABBING_LEVEL=0
    fi
}

__dwmo_reset_nesting() {
    __DWMO_TABBING_LEVEL=0
}

__dwmo_output_echostuff() {
    local msg
    local no_newline
    local tabbing
    local tabbing_level
    local formatting
    local error_formatting
    local info_formatting
    local success_formatting
    local details_formatting
    local end_formatting
    local output_threshold

    msg=""
    no_newline=""
    tabbing=""
    tabbing_level=0
    formatting=""
    error_formatting="\033[0;41m"
    info_formatting="\033[0;33m"
    success_formatting="\033[0;32m"
    details_formatting="\033[0;36mVV: "
    end_formatting="\033[0;0m"
    output_threshold=1

    while [[ -n "${1:-}" ]]; do
    case "$1" in
        -n)
            no_newline="-n"
            shift
            ;;
        -f|--no-format)
            # This allows you to get really fancy with this library
            formatting=""
            shift
            ;;
        --|--unnested)
            unnest_output
            shift
            ;;
        ++|--nested)
            nest_output
            shift
            ;;
        ++--|--++|--reset-nesting)
            reset_nesting
            shift
            ;;
        --output-threshold=*)
            output_threshold=${1#--output-threshold=}
            
            # Clever trick to check if variable is an integer
            if [ "$output_threshold" -eq "$output_threshold" ] 2>/dev/null
            then
                # We expect a number. noop for syntax reasons
                :
            else
                echo "Error: output-threshold must be a number. Got '$output_threshold'"
                return 1
            fi
            shift
            ;;
        --error)
            formatting="$error_formatting"
            shift
            ;;
        --info)
            formatting="$info_formatting"
            shift
            ;;
        --success)
            formatting="$success_formatting"
            shift
            ;;
        --detail)
            formatting="$details_formatting"
            shift
            ;;
        *)
            msg="$msg$1"
            shift
            ;;
    esac
done
    
    # Get desired output tabbing
    for ((i = 0; i < "$__DWMO_TABBING_LEVEL"; i++)); do
        tabbing="$tabbing    "
    done

    # __DWMO_VERBOSITY:     How verbose we are feeling
    # output_threshold:     How verbose we need to be feeling to see output
    if [[ "$__DWMO_VERBOSITY" -lt "$output_threshold" ]]; then
        return 0;
    fi

    if [[ -z "$formatting" ]]; then
        echo ${no_newline:-} "$tabbing""$msg"
    else 
        echo -e ${no_newline:-} "$tabbing""${formatting}${msg}${end_formatting}" >&2
    fi

    return 0 
}

nest_output() {
    __dwmo_nest_output "$@"
}

unnest_output() {
    __dwmo_unnest_output "$@"
}

reset_nesting() {
    __dwmo_reset_nesting "$@"
}

echoerr() {
    output_echostuff --output-threshold=0 --error "$@"
}

echosuccess() {
    output_echostuff --success "$@"
}

echoinfo() {
    output_echostuff --info "$@"
}

echodetail() {
    output_echostuff --output-threshold=2 --detail "$@"
}

