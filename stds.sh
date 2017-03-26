# This file is meant to be sourced

set -euo pipefail

# Best approximation for current running dir
STD_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "STD_LIB_DIR: $STD_LIB_DIR"
echo -n "Dir: " "$(pwd)"
echo
. "$STD_LIB_DIR"/argsparse.sh
. "$STD_LIB_DIR"/output.sh

# 0 Is quiet 					--quiet
# 1 Is regular
# 2 Is verbose 			-v 		--verbose
# 3 Is just ridiculous 	-vv 	--very-verbose
IO_VERBOSITY=1 

