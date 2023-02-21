#!/usr/bin/env bash

# Constants to export to all modules
declare -xr __PROJECT_ROOT__="$(dirname "$(readlink -f "$0")")"
declare -xr __PROJECT_BIN__="$__PROJECT_ROOT__/bin"
declare -xr __PROJECT_CONFIG__="$__PROJECT_ROOT__/config"
declare -xr __PROJECT_MODULES__="$__PROJECT_ROOT__/modules"
declare -xr __PROJECT_SCRIPTS__="$__PROJECT_ROOT__/scripts"


###############################################################################
####                       [common-installer loader]                       ####
###############################################################################


#   [required]
#       __COMMON_INSTALLER_LOADER__     Base filename of this module loader.
#                                       Constant will be exported to all modules.
#
declare -xr __COMMON_INSTALLER_LOADER__="$(basename -s .sh "$0")"


#   [required]
#       __COMMON_SCRIPTS_PATH__         Path to directory containing common-*.sh
#                                       Constant will be exported to all modules.
#
declare -xr __COMMON_SCRIPTS_PATH__="$__PROJECT_SCRIPTS__/bash-common-scripts"


#   [required]
#       MENU_TITLE                      Title text to display in the menu header.
#       MENU_DESCRIPTION                Description of loader. May contain multiple lines.
#       MENU_PROMPT                     User input prompt. May contain multiple lines.
#
declare MENU_TITLE="Installer for Lego Mindstorms NXT Tools"
declare MENU_DESCRIPTION=\
"The following is a collection of scripts for configuring Linux to interact with the Lego Mindstorms NXT.
> Enter a module name to learn more. The system will not be modified without your permission.
> Enter 'help' to list all valid internal commands.
> Press CTRL+C to abort the script at any time."
declare MENU_PROMPT="Enter module names or commands, or type 'x' to exit:"
 

#   [optional]
#       MENU_COMMANDS                   Associative array in which:
#                                         ["keys"] are user input keywords, corresponding to
#                                         "values", which are executable strings of bash commands.
#                                       MENU_COMMANDS overrides __DEFAULT_MENU_COMMANDS__ where both have the same keys.
#
declare -A MENU_COMMANDS=(
)


#   [required]
#       MODULE_PATHS                    Array containing one or more paths:
#                                         - Directories to search (top level only) for module.sh files
#                                         - Direct paths to module.sh files
#
declare -a MODULE_PATHS=(
    "$__PROJECT_MODULES__"
    "$__PROJECT_MODULES__/nxt"
)
 
 
#   [optional]
#       __ARGS__                        Associative array in which:
#                                         ["keys"] are command-line flags (taking one positional argument after each), with
#                                         "values", which are the default values of the arguments if not specified.
#                                       __ARGS__ overrides __DEFAULT_LOADER_ARGS__ where both have the same keys.
#                                       This array and its contents are passed to each module.
#
declare -A __ARGS__=(
    ["logfile"]="$__PROJECT_ROOT__/nxt-tools.log"
)


#   [required]
#       source "$__COMMON_SCRIPTS_PATH__/common-installer.sh"   Import the required functions and other dependencies.
#       begin_module_loader "$@"                                Starts the module loader.
#
source "$__COMMON_SCRIPTS_PATH__/common-installer.sh"
if [[ "$?" -ne 0 ]]; then
    echo "Error loading required source: $__COMMON_SCRIPTS_PATH__/common-installer.sh"
    echo "Please run:"
    echo "  git submodule update --init --recursive"
    echo ""
    exit 1
fi
begin_module_loader "$@"

###############################################################################
