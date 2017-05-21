# This file is meant to be sourced
# -*- tab-width: 4; encoding: utf-8 -*-
#
## @file output.sh
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

#######################################
# Verbosity level
# Increase the verbosity level to get more output from a script
# Reduce it to keep it quiet.
#
# The default Output threshold is 1. So when __DWMO_VERBOSITY is 1
# Any calls to __dwmo_output will be output.
# However, a call to __dwmo_output --output-threshold=2 will not output
# 
#######################################
__DWMO_VERBOSITY=1

#######################################
# Tabbing Level
#
# The higher the tabbing level, the more tabs are placed before output.
#
# Increase the tabbing level with:
# __dwmo_output ++
#
# Decrease the tabbing level with:
# __dwmo_output --
#
#######################################
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

#######################################
# A command to call with the unformatted message
# for every call to output
#
# If there is a registered logger, 
# It will be called with each unformatted message before it is printed
# 
# The Logger can be a function or a program or even a bash builtin
#
# Globals:
#   integer __DWMO_REGISTERED_LOGGER
#
# Arguments:
#   Logger path: "/usr/bin/mylogger"
#
# Returns:
#   None
#
#
# Example:
#     logger() {
#         local msg="$1"
#         echo "$msg" >> "$DIR"/logs.txt
#     }
#
#      __dwmo_register_logger logger
#
#######################################
__DWMO_REGISTERED_LOGGER=""

__dwmo_register_logger() {
    __DWMO_REGISTERED_LOGGER="$@"
}

__dwmo_output() {
    local msg=""
    local no_newline="\n"
    local tabbing=""
    local tabbing_level=0
    local formatting=""
    local logger_msg=""
    local error_formatting="\033[0;41m"
    local info_formatting="\033[0;33m"
    local success_formatting="\033[0;32m"
    local details_formatting="\033[0;36m: "
    local end_formatting="\033[0;0m"
    local checkmark="✔"
    local ballot_x="✘"
    local output_threshold=1

    while [[ -n "${1:-}" ]]; do
    case "$1" in
        -n)
            no_newline=""
            shift
            ;;
        --|--unnested)
            __dwmo_unnest_output
            shift
            ;;
        ++|--nested)
            __dwmo_nest_output
            shift
            ;;
        ++--|--++|--reset-nesting)
            __dwmo_reset_nesting
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
        -k|--checkmark)
            msg="$msg${formatting}$checkmark ${end_formatting}"

            if [[ ! -z "$__DWMO_REGISTERED_LOGGER" ]]; then
                logger_msg="${logger_msg}${1}"
            fi
            shift
            ;;
        -x|--ballotx)
            msg="$msg${formatting}$ballot_x ${end_formatting}"

            if [[ ! -z "$__DWMO_REGISTERED_LOGGER" ]]; then
                logger_msg="${logger_msg}${1}"
            fi
            shift
            ;;
        *)
            msg="$msg${formatting}$1${end_formatting}"

            if [[ ! -z "$__DWMO_REGISTERED_LOGGER" ]]; then
                logger_msg="${logger_msg}${1}"
            fi
            shift
            ;;
        esac
    done
    
    # Get desired output tabbing
    for ((i = 0; i < "$__DWMO_TABBING_LEVEL"; i++)); do
        tabbing="$tabbing    "
    done

    if [[ ! -z "$__DWMO_REGISTERED_LOGGER" ]]; then
        ($__DWMO_REGISTERED_LOGGER "$logger_msg")
    fi

    # __DWMO_VERBOSITY:     How verbose we are feeling
    # output_threshold:     How verbose we need to be feeling to see output
    if [[ "$__DWMO_VERBOSITY" -lt "$output_threshold" ]]; then
        return 0
    fi

    printf "$tabbing""$msg""$no_newline"

    return 0
}

#######################################
# Predefined Functions
#
# These are a set of useful predefined functions for output.
# They include the functions for nesting output, and for different formats of output.
#
# If you wish to define your own output functions using these names,
# set  $__DWMO_DONT_USE_PREDEFINED_FUNCS="any non-null value"
#
#######################################
if [[ ! -z ${__DWMO_DONT_USE_PREDEFINED_FUNCS:-word} ]]; then

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
        __dwmo_output --output-threshold=0 --error "$@" >&2
    }

    echosuccess() {
        __dwmo_output --success "$@"
    }

    echoinfo() {
        __dwmo_output --info "$@"
    }

    echodetail() {
        __dwmo_output --output-threshold=2 --detail "$@"
    }

fi
