#!/usr/bin/env bash

# ***************************************
# FUNCTIONS AND VARIABLES
# ***************************************
# Paths
root_dir="$(dirname "$(readlink -f "$0")")"
scripts_dir="$root_dir/scripts"
config_dir="$root_dir/config"
bin_dir="$root_dir/bin"
global_bin="/usr/local/bin"     # Executable binaries
global_lib="/usr/local/lib"     # Precompiled sources (.a, .so)
global_src="/usr/local/src"     # Source code
global_inc="/usr/local/include" # Headers
global_etc="/usr/local/etc"     # Config files, etc.
global_opt="/opt"               # Large "features"; ROS, Java, etc.
logfile="$root_dir/nxt-tools.log"
sysconfig_routine_searchpaths=( "$scripts_dir" "$scripts_dir/nxt" )

# Import functions
sources=(   "$scripts_dir/bash-common-scripts/common-functions.sh" 
            "$scripts_dir/bash-common-scripts/common-tables.sh"        
            "$scripts_dir/bash-common-scripts/common-io.sh"        
            "$scripts_dir/bash-common-scripts/common-ui.sh"        
            "$scripts_dir/bash-common-scripts/common-sysconfig.sh"         )
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

# find_sysconfig_scripts {tablename} {searchpath}
function find_sysconfig_scripts() {
    local -n _tab=$1
    local searchpath="$2"

    local -a optional_keys=( "description" "requires" "longname" "longdescription" )
    local colnames="file verified ${optional_keys[@]}"
    local file name val

    if ! is_table _tab; then
        table_create _tab -colnames "$colnames"
    fi

    printf "Searching for sysconfig scripts in $searchpath...\n"
    for file in "$searchpath"/*; do
        # Only search .sh files
        if [[ ! -f "$file" ]]; then continue; fi
        if [[ "$file" != *.sh ]]; then continue; fi

        # Ensure the file has a "name" key
        if ! find_key_value_pair name "$file" "name"; then continue; fi
        if [[ "$name" == "" ]]; then continue; fi
        table_set _tab "$name" "file" "$file"
        printf "Found sysconfig script: %s\n" "$name"

        # Check for the rest of the keys
        for key in ${optional_keys[@]}; do
            if find_key_value_pair val "$file" "$key"; then
                table_set _tab "$name" "$key" "$val"
            fi
        done

        # Ask the script to verify its status
        /usr/bin/env bash "$file" --verify-only
        if [[ $? -eq 0 ]]; then table_set _tab "$name" "verified" "$TRUE"
        else                    table_set _tab "$name" "verified" "$FALSE"
        fi
    done
}


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
    echo "Will autorun the following scripts: "
    printvar autoruns -showname false
    echo ""
fi

logfile="${args[log]}"


# ***************************************
# SCRIPT START
# ***************************************
require_non_root
echo "" > "$logfile"

# Search for install scripts
declare -A scripts=()
for dir in "${sysconfig_routine_searchpaths[@]}"; do
    if [[ ! -d "$dir" ]]; then continue; fi
    find_sysconfig_scripts scripts "$dir"
done
printvar scripts

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

# Auto mode; run the specified scripts then exit.
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
