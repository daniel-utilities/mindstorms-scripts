#!/usr/bin/env bash

###############################################################################
####                       [common-installer module]                       ####
###############################################################################
####                                                                       ####
####    In each [required] section below, modify the definitions to fit    ####
####    the application. Any [optional] sections may be omitted or blank.  ####
####                                                                       ####
###############################################################################
#   Do not edit this section!
__MODULE_TEMPLATE_VERSION__="1.0"


###############################################################################
####                         VARIABLE DEFINITIONS                          ####
###############################################################################

#   [required]
#       MODULE              Name which represents this module.
#       TITLE               Longer, more descriptive name. Max 40 characters.
#
MODULE="usb"
TITLE="Mindstorms USB Configuration"


#   [optional]
#       REQUIRES            Space-separated list of modules on which this module depends
#       AUTHOR              Author(s) of software associated with this module
#       EMAIL               Email address of author
#       WEBSITE             Web address most closely associated with this software
#       HIDDEN              If "true", hides this module from the UI menu.
#
REQUIRES=""
AUTHOR=""
EMAIL=""
WEBSITE="https://github.com/daniel-utilities/mindstorms-scripts"
HIDDEN="false"


#   [optional]
#       ****                Define additional global variables in this section.
#                           These will be accessible by all module functions.
#       
REPO_URL="https://github.com/pybricks/pbrick-rules.git"
REPO_BRANCH="main"
REPO_NAME=""; get_basename REPO_NAME "$REPO_URL" ; REPO_NAME="${REPO_NAME%.*}"
REPO_DIR="$__TEMP_DIR__/$REPO_NAME"
INSTALL_FILES=(
    "$REPO_DIR/debian/pbrick-rules.pbrick.udev : /etc/udev/rules.d/50-pbrick.rules"
    "$PROJECT_CONFIG/udev/70-nxt.rules         : /etc/udev/rules.d/70-nxt.rules"
    "$PROJECT_CONFIG/udev/nxt_event_handler.sh : /etc/udev/nxt_event_handler.sh"
)
PERMGROUPS=(
    plugdev dialout
)


###############################################################################
####                         FUNCTION DEFINITIONS                          ####
###############################################################################

#   [required]
#     on_import
#         Called after module is sourced and validated.
#         May use this to initialize global variables, perform system checks, or cancel the import.
#         Function may not modify the system.
#     on_status_check
#         Check and return the installation status of this module.
#         Function may not modify the system.
#     on_print
#         Print information about what system changes will be made during the installation process.
#         Function may not modify the system.
#     on_install
#         Install the module. Called after permission is granted to make changes to the system.
#     on_exit
#         Run installation clean-up tasks.
#         Called after on_install, regardless if on_install completed successfully or not.
#
#     Within each of these functions, the following global variables are guaranteed to be defined:
#         __ARGS__                 Associative array containing all command-line values passed to the module loader.
#         __AUTOCONFIRM__          If $__AUTOCONFIRM__ == $TRUE, the module was started in unattended mode (all user input prompts should be suppressed).
#         __ALLOW_ROOT__           If $__ALLOW_ROOT__ == $TRUE, the user has specified that the module should not prevent being run as root.
#         __FORCE__                If $__FORCE__ == $TRUE, the module is reinstalled even if it is already installed.
#         __LOADER_BASE_NAME__     Base filename of the loader which started this module. 
#         __LOGFILE__              Path to log file. All stdout and stderr is logged to this file automatically (do not write to this!)
#         __TERMINAL_WIDTH__       Width of the current terminal window, in characters.
#         __TEMP_DIR__             Temporary directory dedicated to the module loader.
#
#   


#   [required]
#     on_import
#         Called after module is sourced and validated.
#         May use this to initialize global variables, perform system checks, or cancel the import.
#         Function may not modify the system.
#       Traps:
#         ERR   If any command in this function returns a nonzero exit code, the script will exit.
#       Inputs:
#         None
#       Outputs:
#         $?    Numeric exit code. Return any nonzero value to cancel the module import.
#
function on_import() {
    # Check these directories are set and valid. They should've been defined by the module loader.
    [[ -d "$PROJECT_ROOT" ]]
    [[ -d "$PROJECT_BIN" ]]
    [[ -d "$PROJECT_CONFIG" ]]
    [[ -d "$PROJECT_MODULES" ]]
    [[ -d "$PROJECT_SCRIPTS" ]]

    # Require that the script was not run as root or with sudo.
    [[ "$__ALLOW_ROOT__" == "$TRUE" ]] || require_non_root
}



#   [required]
#     on_status_check
#         Check and return the installation status of this module.
#         Function may not modify the system.
#       Inputs:
#         None
#       Outputs:
#         $?    Numeric exit code. Must return one of the following:
#                 return $__MODULE_STATUS_INSTALLED__
#                 return $__MODULE_STATUS_NOT_INSTALLED__
#                 return $__MODULE_STATUS_UNKNOWN__
#
function on_status_check() {
    if [[ ! -e "/etc/udev/rules.d/50-pbrick.rules" ]]; then
        return $__MODULE_STATUS_NOT_INSTALLED__
    fi

    return $__MODULE_STATUS_INSTALLED__
}



#   [required]
#     on_print
#         Print information about what system changes will be made during the installation process.
#         Function may not modify the system.
#       Traps:
#         ERR   If any command in this function returns a nonzero exit code, the script will exit.
#       Inputs:
#         None
#       Outputs:
#         &1    Function can print to stdout.
#
function on_print() {
    # Print info
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



#   [required]
#     on_install
#         Install the module. Called after permission is granted to make changes to the system.
#       Traps:
#         ERR   If any command in this function returns a nonzero exit code, the script will exit.
#         INT   If the user presses CTRL+C while this function is running, the script will exit.
#         EXIT  If the script exits while within this function, the on_exit function will be called.
#       Inputs:
#         &0    Function can read from stdin. (Not recommended; user approval has already been granted.)
#       Outputs:
#         &1    Function can print to stdout.
#
function on_install() {
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



#   [required]
#     on_exit
#         Run installation clean-up tasks.
#         Called after on_install, regardless if on_install completed successfully or not.
#       Inputs:
#         None
#       Outputs:
#         &1    Function can print to stdout.
#
function on_exit() {
    echo "  Deleting $REPO_DIR..."
    rm -rf "$REPO_DIR" &> /dev/null || sudo rm -rf "$REPO_DIR"
}

###############################################################################
