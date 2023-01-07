#!/usr/bin/env bash

# ***************************************
# FUNCTIONS AND VARIABLES
# ***************************************
# Paths
root_dir="$(dirname "$(readlink -f "$0")")"
bin_dir="$root_dir/bin"
config_dir="$root_dir/config"
modules_dir="$root_dir/modules"
scripts_dir="$root_dir/scripts"
logfile="$root_dir/nxt-tools.log"
module_searchpaths=( "$modules_dir" "$modules_dir/nxt" )

# System paths
global_bin="/usr/local/bin"     # Executable binaries
global_lib="/usr/local/lib"     # Precompiled sources (.a, .so)
global_src="/usr/local/src"     # Source code
global_inc="/usr/local/include" # Headers
global_etc="/usr/local/etc"     # Config files, etc.
global_opt="/opt"               # Large "features"; ROS, Java, etc.

# Import functions
sources=(   "$scripts_dir/bash-common-scripts/common-functions.sh" 
            "$scripts_dir/bash-common-scripts/common-io.sh"        
            "$scripts_dir/bash-common-scripts/common-ui.sh"        
            "$scripts_dir/bash-common-scripts/common-tables.sh"        
            "$scripts_dir/bash-common-scripts/common-installer.sh"         )
for i in "${sources[@]}"; do
    if [ -e "$i" ]; then
        source "$i"
    else
        echo "Error - could not find required source: $i"
        echo "Please run:"
        echo "  git submodule update --init --recursive --remote"
        echo ""
        exit 1
    fi
done

# Menu configuration
menu_title=$'Installer for Lego Mindstorms NXT Tools'
menu_description=\
$'The following is a collection of installation scripts for interacting with the Lego Mindstorms NXT on Linux.
Most (or all) require sudo (superuser) privilege.
Press CTRL-C to terminate the script at any time.

Options: '
menu_prefix='  '
menu_prompt='Enter an option: '
declare -A menu_opts=(
          ["0"]="            |  Exit"
        ["usb"]="(Required)  |  Install USB support for Mindstorms NXT"
         ["bt"]="(Optional)  |  Install Bluetooth support for Mindstorms NXT"
   ["nexttool"]="(Optional)  |  Install NeXTTool"
     ["libnxt"]="(Optional)  |  Install LibNXT"
   ["compiler"]="(Optional)  |  Install ARM EABI compiler and debugger"
)

# Map menu items to function calls
declare -A commands=(
            ["0"]="exit 0"
          ["usb"]="install_usb_config -config \"$config_dir\" "
    ["bluetooth"]="install_bluetooth_config -config \"$config_dir\" "
     ["nexttool"]="install_nexttool -config \"$config_dir\" -install \"$install_dir\" "
       ["libnxt"]="install_libnxt -config \"$config_dir\" -install \"$install_dir\" "
     ["compiler"]="echo 'Not currently implemented.'; pause "
)


# ***************************************
# ARGS
# ***************************************
declare -A args=( ["confirm"]="true"
                      ["log"]="$logfile" )
fast_argparse args "" "confirm autorun log" "$@"

if [[ "${args[confirm],,}" == "false" ]]; then
    __AUTOCONFIRM=$TRUE
    echo "Skipping user confirmation prompts."
    echo ""
fi

autoruns_str="${args[autorun]}"
declare -a autoruns=()
if [[ "$autoruns_str" != "" ]]; then
    str_to_arr autoruns autoruns_str -e ' '
    echo "Will autorun the following modules: "
    printvar autoruns -showname false
    echo ""
fi

logfile="${args[log]}"


# ***************************************
# SCRIPT START
# ***************************************
require_non_root
echo "" > "$logfile"

# Search for installer modules
declare -A modules=()
for dir in "${module_searchpaths[@]}"; do
    if [[ ! -d "$dir" ]]; then continue; fi
    printf "Searching for installer modules in $dir...\n"
    find_installer_modules modules "$dir"
done
printvar modules

# Normal mode; present a menu for the user to pick from
if [[ "${#autoruns[@]}" -eq 0 ]]; then

    #clear 
    while true; do
        user_selection_menu  menu_opts                  \
                             -title "$menu_title"       \
                             -description "$menu_description" \
                             -prefix "$menu_prefix"     \
                             -prompt "$menu_prompt"
        echo ""

        command="${commands[$REPLY]}"
        if [[ "$command" != "" ]]; then
            eval "$command" > >(tee -a -- "$logfile") 2>&1
            sleep 1
            printf "\n\n\n"
        fi
    done

# Auto mode; run the specified modules then exit.
else

    for autorun in "${autoruns[@]}"; do
        command="${commands[$autorun]}"
        if [[ "$command" != "" ]]; then
            echo "$autorun: $command"
            eval "$command" > >(tee -a -- "$logfile") 2>&1
            sleep 1
            printf "\n\n\n"
        fi
    done
    exit 0
fi

