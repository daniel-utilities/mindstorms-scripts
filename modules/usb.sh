#!/usr/bin/env bash

###############################################################################
####                       [common-installer module]                       ####
###############################################################################

#   [required]
#       __COMMON_INSTALLER_MODULE__     Base filename of this module.
#
__COMMON_INSTALLER_MODULE__="$(basename -s .sh "$0")"


#   [required]
#       module              Name which represents this module.
#       title               Longer, more descriptive name. Max 40 characters.
#
module="usb"
title="Mindstorms USB Configuration"


#   [optional]
#       requires            List of modules on which this module depends
#       author              Author(s) of software associated with this module
#       email               Email address of author
#       website             Web address most closely associated with this software
#       hidden              If "true", hides this module from the UI menu.
#
requires=""
author=""
email=""
website="https://github.com/daniel-utilities/mindstorms-scripts"
hidden="false"

###############################################################################

#   [required]
#   1.  module_init()       Initialization routines, global variable definitions, etc.
#                               To define global variables, use:  declare -g NAME
#                               Variables defined here will be defined in all other functions.
#   2.  module_check()      Returns the installation status of this module.
#                               return $__MODULE_STATUS_INSTALLED__
#                               return $__MODULE_STATUS_NOT_INSTALLED__
#                               return $__MODULE_STATUS_UNKNOWN__
#   3.  module_info()       Print info text about the module.
#                               This function outputs to the terminal, but not to __LOGFILE__.
#   4.  module_run()        Main body of module code.
#                               Any command which returns a non-0 exit value will immediately terminate the module.
#                               All output of this function is logged to __LOGFILE__ .
#   5.  module_exit()       Callback which executes when script exits.
#                               __TEMP_DIR__ is automatically deleted after module_exit completes.
#
#       Within each of these functions, the following global variables are defined:
#         __ARGS__                        Associative array containing all command-line values passed to the module loader.
#         __LOGFILE__                     Path to log file. All stdout and stderr is logged to this file automatically.
#         __AUTOCONFIRM__                 If $__AUTOCONFIRM__ == $TRUE, user confirmation prompts are suppressed.
#         __COMMON_INSTALLER_LOADER__     Base filename of the loader which started this module. 
#         __COMMON_SCRIPTS_PATH__         Path to directory containing common-*.sh
#         __TERMINAL_WIDTH__              Width of the current terminal window, in characters.
#         __TEMP_DIR__                    Temporary directory dedicated for use by this module.
#
#   
function module_init() {
    # Check that the required environment variables are defined. They should've been exported by the module loader.
    [[ -v __PROJECT_ROOT__ ]];
    [[ -v __PROJECT_BIN__ ]];
    [[ -v __PROJECT_CONFIG__ ]];
    [[ -v __PROJECT_MODULES__ ]];
    [[ -v __PROJECT_SCRIPTS__ ]];

    # Global variables
    declare -g  REPO_URL="https://github.com/pybricks/pbrick-rules.git"
    declare -g  REPO_BRANCH="main"
    declare -g  REPO_NAME=""; get_basename REPO_NAME "$REPO_URL" ; REPO_NAME="${REPO_NAME%.*}"
    declare -g  REPO_DIR="$__TEMP_DIR__/$REPO_NAME"
    declare -ga INSTALL_FILES=(
        "$REPO_DIR/debian/pbrick-rules.pbrick.udev     : /etc/udev/rules.d/50-pbrick.rules"
        "$__PROJECT_CONFIG__/udev/70-nxt.rules         : /etc/udev/rules.d/70-nxt.rules"
        "$__PROJECT_CONFIG__/udev/nxt_event_handler.sh : /etc/udev/nxt_event_handler.sh"
    )
    declare -ga PERMGROUPS=(
        plugdev dialout
    )

    # Require that the script was not run as a root user
    require_non_root
}


function module_check() {
    [[ ! -e "/etc/udev/rules.d/50-pbrick.rules" ]] && return $__MODULE_STATUS_NOT_INSTALLED__
    return $__MODULE_STATUS_INSTALLED__
}


function module_info() {
    echo "UDEV rules are required for user access to hardware devices, including all Mindstorms devices. Without this configuration, all tools will require 'sudo' (root) privilege and many scripts will break."
    echo "Where applicable, kernel modules will be enabled so Mindstorms devices always have the correct drivers available."
    echo ""
    echo "Repository \"$REPO_NAME\" will be downloaded:"
    echo "  URL:    $REPO_URL"
    [[ "$REPO_BRANCH" != "" ]] && echo "  Branch: $REPO_BRANCH"
    echo "  Path:   $REPO_DIR"
    echo ""
    echo "The following files will be installed:"
    print_var INSTALL_FILES -showname "false" -wrapper ""
    echo ""
    echo "User '$USER' will be added to the following groups:"
    echo "  ${PERMGROUPS[@]}"
    echo ""
}


function module_run() {
    echo "Downloading repository: $REPO_NAME"
    cd "$__TEMP_DIR__"
    git_latest "$REPO_URL" "$REPO_BRANCH"
    echo ""

    echo "Installing UDEV rules..."
    multi_copy INSTALL_FILES -mkdir "false" -overwrite "false" -su "true"
    echo ""

    for groupname in "${PERMGROUPS[@]}"; do
        echo "Adding user $USER to group $groupname..."
        sudo groupadd -f "$groupname"
        sudo usermod -aG "$groupname" $USER
    done
    echo ""

    echo "Reloading UDEV rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger
}


function module_exit() {
    :
}

###############################################################################

#   [required]
#       source "$__COMMON_SCRIPTS_PATH__/common-installer.sh"   Import the required functions and other dependencies.
#       begin_module "$@"                                       Starts the module.
#
if [[ ! -v __COMMON_INSTALLER_LOADER__ || ! -v __COMMON_SCRIPTS_PATH__ ]]; then
    echo "Error: $(basename -s .sh "$0") is a [common-installer module]"
    echo "  and can only be run by a [common-installer loader]."
    echo ""
    exit 1
fi
source "$__COMMON_SCRIPTS_PATH__/common-installer.sh"
if [[ "$?" -ne 0 ]]; then
    echo "Error loading required source: $__COMMON_SCRIPTS_PATH__/common-installer.sh"
    echo "Please run:"
    echo "  git submodule update --init --recursive"
    echo ""
    exit 1
fi
begin_module "$@"

###############################################################################
