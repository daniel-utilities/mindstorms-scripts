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
MODULE_TEMPLATE_VERSION="1.1"


###############################################################################
####                         VARIABLE DEFINITIONS                          ####
###############################################################################

#   [required]
#       MODULE              Name which represents this module. No spaces.
#       TITLE               Longer, more descriptive name. Max 40 characters.
#
MODULE="libnxt"
TITLE="LibNXT (fwflash, fwexec)"


#   [optional]
#       REQUIRES            Space-separated list of modules on which this module depends
#       AUTHOR              Author(s) of software associated with this module
#       EMAIL               Email address of author
#       WEBSITE             Web address most closely associated with this software
#       HIDDEN              If "true", hides this module from the UI menu.
#
REQUIRES="usb"
AUTHOR="David Anderson, Lawrie Griffiths, Nicolas Schodet"
EMAIL=""
WEBSITE="https://github.com/schodet/libnxt"
HIDDEN="false"


#   [optional]
#       ****                Define additional global variables in this section.
#                           These will be accessible by all module functions.
#       


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
#         __ARGS__                  Associative array containing all command-line values passed to the module loader.
#         __AUTOCONFIRM__           If $__AUTOCONFIRM__ == $TRUE, the module was started in unattended mode (all user input prompts should be suppressed).
#         __ALLOW_ROOT__            If $__ALLOW_ROOT__ == $TRUE, the user has specified that the module should not prevent being run as root.
#         __FORCE__                 If $__FORCE__ == $TRUE, the module is reinstalled even if it is already installed.
#         __LOADER_SCRIPT_PATH__    Absolute path to the loader script which launched this module.
#         __LOADER_BASENAME__       Filename of the loader script (without the .sh extension).
#         __LOADER_DIR__            Absolute path to directory containing the loader script.
#         __LOGFILE__               Absolute path to log file. All stdout and stderr is logged to this file automatically (do not write to this!).
#         __TERMINAL_WIDTH__        Width of the current terminal window, in characters.
#         __TEMP_DIR__              Temporary directory dedicated to the module loader.
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
    [[ -d "$PROJECT_BIN_DIR" ]]
    [[ -d "$PROJECT_CONFIG_DIR" ]]
    [[ -d "$PROJECT_SCRIPTS_DIR" ]]

    # Require that the script was not run as root (unless "--allow-root true" was specified on the command line)
    [[ "$__ALLOW_ROOT__" == "$TRUE" ]] || require_non_root

    # Set Global variables
    declare -g INSTALL_PACKAGES_APT="git gcc g++ build-essential meson gcc-arm-none-eabi scdoc python3 libusb-1.0-0 libusb-1.0-0-dev"

    declare -g REPO_URL="https://github.com/schodet/libnxt.git"
    declare -g REPO_BRANCH="master"
    declare -g REPO_NAME=""; get_basename REPO_NAME "$REPO_URL" ; REPO_NAME="${REPO_NAME%.*}"
    declare -g REPO_DIR="$__TEMP_DIR__/$REPO_NAME"

    declare -g INSTALL_PREFIX="${__ARGS__[prefix]:-/usr/local}"
    clean_path INSTALL_PREFIX "$INSTALL_PREFIX"

    declare -g INSTALL_FILES_BIN=(
        "$REPO_DIR/build/fwflash   : $INSTALL_PREFIX/bin/"
        "$REPO_DIR/build/fwexec    : $INSTALL_PREFIX/bin/"
    )
    declare -g INSTALL_FILES_LIB=(
        "$REPO_DIR/build/*.a       : $INSTALL_PREFIX/lib/" 
    )
    declare -g INSTALL_FILES_INC=(
        "$REPO_DIR/*.h             : $INSTALL_PREFIX/include/libnxt/"
        "$REPO_DIR/build/*.h       : $INSTALL_PREFIX/include/libnxt/"
        "$REPO_DIR/build/flash_write/crt0.o    : $INSTALL_PREFIX/include/libnxt/flash_write/"
        "$REPO_DIR/build/flash_write/flash.bin : $INSTALL_PREFIX/include/libnxt/flash_write/"
        "$REPO_DIR/build/flash_write/flash.elf : $INSTALL_PREFIX/include/libnxt/flash_write/"
        "$REPO_DIR/build/flash_write/flash.o   : $INSTALL_PREFIX/include/libnxt/flash_write/"
    )
    declare -g INSTALL_FILES_SRC=(
        "$REPO_DIR/*.c             : $INSTALL_PREFIX/src/libnxt/"
        "$REPO_DIR/*.py            : $INSTALL_PREFIX/src/libnxt/"
        "$REPO_DIR/flash_write/*.c : $INSTALL_PREFIX/src/libnxt/flash_write/"
        "$REPO_DIR/flash_write/*.s : $INSTALL_PREFIX/src/libnxt/flash_write/"
    )
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
    if [[ ! -x "$(command -v fwflash)" ]]; then
        return $__MODULE_STATUS_NOT_INSTALLED__
    fi
    if [[ ! -x "$(command -v fwexec)" ]]; then
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
    echo "LibNXT provides a linkable binary and C headers for developing software which communicates with the NXT brick using libusb. It also provides two command-line utilities which are required components of some toolchains:"
    echo "  -  fwflash: Downloads firmware to an NXT brick."
    echo "  -  fwexec:  Runs a specially-compiled binary directly in the NXT's RAM."
    echo ""
    echo "The following APT packages will be installed:" 
    echo "  $INSTALL_PACKAGES_APT"
    echo ""
    echo "Repository \"$REPO_NAME\" will be downloaded:"
    echo "  URL:    $REPO_URL"
    [[ "$REPO_BRANCH" != "" ]] && echo "  Branch: $REPO_BRANCH"
    echo "  Path:   $REPO_DIR"
    echo ""
    echo "Files will be installed to:"
    echo "  Prefix: $INSTALL_PREFIX"
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
    echo "Installing packages with apt-get:"
    echo "  \"$APT_INSTALL\""
    sudo apt-get update || echo "Warning: Failed apt-get update. Might fail apt-get install as well."
    sudo apt-get -yq install $INSTALL_PACKAGES_APT
    echo ""

    echo "Downloading repository: $REPO_NAME"
    cd "$__TEMP_DIR__"
    git_latest "$REPO_URL" "$REPO_BRANCH"
    echo ""

    echo "Building LibNXT..."
    cd "$REPO_DIR"
    meson build
    cd build
    meson compile
    echo ""

    echo "Installing files..."
    multi_copy INSTALL_FILES_LIB -mkdir "true" -overwrite "true" -su "auto"
    multi_copy INSTALL_FILES_INC -mkdir "true" -overwrite "true" -su "auto"
    multi_copy INSTALL_FILES_SRC -mkdir "true" -overwrite "true" -su "auto"
    multi_copy INSTALL_FILES_BIN -mkdir "true" -overwrite "true" -su "auto" -chmod "+x"
    echo ""
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
