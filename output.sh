# This file is meant to be sourced
##set -eu

# -1 Do not stir for you may awaken c'thulhu
#  0 Is quiet    					--quiet
#  1 Is regular
#  2 Is verbose 			-v 		--verbose
#  3 Is just ridiculous 	-vv 	--very-verbose
IO_VERBOSITY=1
IO_TABBING_LEVEL=0
MAX_IO_TABBING=20

nest_output() {
    IO_TABBING_LEVEL="$((++IO_TABBING_LEVEL))"

    # Limit tabbing because at some point it just makes no sense
    if [[ "$IO_TABBING_LEVEL" -gt "$MAX_IO_TABBING" ]]; then
        IO_TABBING_LEVEL="$MAX_IO_TABBING"
    fi
}

unnest_output() {
    IO_TABBING_LEVEL="$((--IO_TABBING_LEVEL))"
    if [[ IO_TABBING_LEVEL -lt 0 ]]; then
        IO_TABBING_LEVEL=0
    fi
}

reset_nesting() {
    IO_TABBING_LEVEL=0

}

output_echostuff() {
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
    for ((i = 0; i < "$IO_TABBING_LEVEL"; i++)); do
        tabbing="$tabbing    "
    done

    # IO_VERBOSITY:         How verbose we are feeling
    # output_threshold:     How verbose we need to be feeling to see output
    if [[ "$IO_VERBOSITY" -lt "$output_threshold" ]]; then
        return 0;
    fi

    if [[ -z "$formatting" ]]; then
        echo ${no_newline:-} "$tabbing""$msg"
    else 
        echo -e ${no_newline:-} "$tabbing""${formatting}${msg}${end_formatting}" >&2
    fi
    return 0 
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
