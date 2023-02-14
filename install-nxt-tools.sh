#!/usr/bin/env bash

# ***************************************
# FUNCTIONS AND VARIABLES
# ***************************************
# Project Paths
declare -A proj=()
proj["root"]="$(dirname "$(readlink -f "$0")")"
proj["work"]="$PWD"
proj["bin"]="${proj[root]}/bin"
proj["config"]="${proj[root]}/config"
proj["modules"]="${proj[root]}/modules"
proj["scripts"]="${proj[root]}/scripts"
module_searchpaths=( "${proj[modules]}"
                     "${proj[modules]}/nxt" )

# Import functions
sources=(   "${proj[scripts]}/bash-common-scripts/common-functions.sh" 
            "${proj[scripts]}/bash-common-scripts/common-io.sh"        
            "${proj[scripts]}/bash-common-scripts/common-ui.sh"        
            "${proj[scripts]}/bash-common-scripts/common-tables.sh"        
            "${proj[scripts]}/bash-common-scripts/common-installer.sh"         )
for i in "${sources[@]}"; do
    if [ -e "$i" ]; then
        source "$i"
    else
        echo "Error - could not find required source: $i"
        echo "Please run:"
        echo "  git submodule update --init --recursive"
        echo ""
        exit 1
    fi
done
require_non_root


# Menu
menu_title="Installer for Lego Mindstorms NXT Tools"
menu_description=\
"The following is a collection of scripts for configuring Linux to interact with the Lego Mindstorms NXT.
Type the [name] of any module to learn more. The system will not be modified without your permission.
Press CTRL-C to exit the script at any point."
menu_prompt="Enter a module name or 'x' to exit:  "

# Default argument values
declare -A args=(
    ["confirm"]="true"
    ["modules"]=""
    ["user"]="root"
    ["installpath"]="/usr/local"
    ["logfile"]="${proj[root]}/nxt-tools.log"
)

# ***************************************
# PARSE ARGS
# ***************************************

# Parse args
printf -v paramlist "%s " "${!args[@]}"
fast_argparse args "" "$paramlist" "$@"

# Arguments to pass through to modules
printf -v module_args -- "-scripts \"%s\" -root \"%s\" -work \"%s\" -bin \"%s\" -config \"%s\" -confirm %s -user %s -installpath \"%s\" " \
    "${proj[scripts]}"     \
    "${proj[root]}"        \
    "${proj[work]}"        \
    "${proj[bin]}"         \
    "${proj[config]}"      \
    "${args[confirm],,}"   \
    "${args[user]}"        \
    "${args[installpath]}"


# ***************************************
# FIND MODULES
# ***************************************
declare -A module_table=()
declare -a module_names=()
for dir in "${module_searchpaths[@]}"; do
    if [[ ! -d "$dir" ]]; then continue; fi
    printf "Searching for installer modules in $dir...\n"
    find_installer_modules module_table "$dir"
done
table_get_rownames module_table module_names

# Validate autorun module names
autorun_modules_str="${args[modules],,}"
declare -a autorun_modules_unvalidated=()
declare -a autorun_modules=()
str_to_arr autorun_modules_unvalidated autorun_modules_str -e ' '
for module_name in "${autorun_modules_unvalidated[@]}"; do
    if has_value module_names "${module_name,,}"; then
        if ! has_value autorun_modules "${module_name,,}"; then # make unique
            autorun_modules+=("${module_name,,}")
        fi
    else
        printf "WARNING: No module found for argument '%s'.\n" "$module_name"
    fi
done
# table_print module_table
printf "\n"


# ***************************************
# DISPLAY UI
# ***************************************
autoconfirm_warn=""
if [[ "${args[confirm],,}" == "false" ]]; then
    __AUTOCONFIRM=$TRUE
    printf -v autoconfirm_warn "WARNING: Skipping user confirmation prompts. Modules will run in fully-automatic mode.\n"
fi

# Reset the logfile
get_title_box titlebox "$menu_title" -width 80
printf "%s\n%s" "$titlebox" "$autoconfirm_warn" > "${args[logfile]}"


# Normal mode; present a menu for the user to pick from
if [[ "${#autorun_modules}" -eq 0 ]]; then

    # Repeat until user exits the script
    while true; do
        # Print info text
        get_term_width terminal_width
        get_title_box titlebox "$menu_title" -width "$terminal_width"
        wrap_string wrapped_description "$menu_description" "$terminal_width"
        printf "\n%s\n%s\n%s\n" "$titlebox" "$autoconfirm_warn" "$wrapped_description"

        # Print menu
        print_installer_modules module_table -width "$terminal_width"
        printf "\n"

        # Collect and validate user input and execute the command
        while true; do
            unset REPLY
            read -r -p "$menu_prompt" 
            user_input="${REPLY,,}"
            trim user_input

            # Match against internal commands first
            case "$user_input" in
                x | exit)     exit 0 ;;
                r | refresh)  get_term_width terminal_width; break ;;
            esac

            # Match against module names second
            if has_value module_names "$user_input"; then
                table_get module_table "$user_input" "hidden" hidden
                if [[ "${hidden,,}" != "true" ]]; then
                    module_name="$user_input"
                    load_installer_module module_table "$module_name" -args "$module_args" -logfile "${args[logfile]}"
                    break;
                fi
            fi
            printf "Invalid input: '%s'\n" "$REPLY"
        done
    done

# Auto mode; run the specified modules then exit.
else
    # Print info text
    get_term_width terminal_width
    get_title_box titlebox "$menu_title" -width "$terminal_width"
    printf "%s\n%s\n" "$titlebox" "$autoconfirm_warn"

    printf "Autorunning the following modules in sequence:\n"
    printvar autorun_modules -showname "false"
    printf "\n"

    # Run each module sequentially
    for module_name in "${autorun_modules[@]}"; do
        load_installer_module module_table "$module_name" -args "$module_args" -logfile "${args[logfile]}"
    done
    exit 0
fi

