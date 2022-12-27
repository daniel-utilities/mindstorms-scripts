#!/usr/bin/env bash

# ***************************************
# FUNCTIONS AND VARIABLES
# ***************************************
root_dir="$(dirname "$(readlink -f "$0")")"
config_dir="$root_dir/config"
bin_dir="$root_dir/bin"

# Import functions from other files
sources=(   "$root_dir/bash-common-scripts/common-functions.sh" 
            "$root_dir/bash-common-scripts/common-io.sh"        
            "$root_dir/bash-common-scripts/common-ui.sh"        
            "$root_dir/installation-routines.sh"                )
for i in "${sources[@]}"; do
    if [ ! -e "$i" ]; then
        echo "Error - could not find required source: $i"
        echo "Please run:"
        echo "  git submodule update --init --recursive --remote"
        echo ""
        exit 1
    else
        source "$i"
    fi
done

declare -A sources

# ***************************************
# ARGS
# ***************************************
declare -A args=( ["skip-prompts"]="false" )
fast_argparse args "" "skip-prompts"

if [[ "${args[skip-prompts],,}" == true ]]; then
    __AUTOCONFIRM=true
fi


# ***************************************
# SCRIPT START
# ***************************************
require_non_root

install_prerequisites
install_udev_rules_nxt
install_nexttool
install_libnxt

