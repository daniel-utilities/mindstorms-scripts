#!/usr/bin/env bash

###############################################################################
####                       [common-installer loader]                       ####
###############################################################################
####                                                                       ####
####    In each [required] section below, modify the definitions to fit    ####
####    the application. Any [optional] sections may be omitted or blank.  ####
####                                                                       ####
###############################################################################
#   Do not edit this section!
LOADER_TEMPLATE_VERSION="1.1"
LOADER_SCRIPT_PATH="$(readlink -f "$0")"        # Absolute path of this script
LOADER_DIR="$(dirname "$LOADER_SCRIPT_PATH")"   # Directory containing this script


###############################################################################
####                         VARIABLE DEFINITIONS                          ####
###############################################################################

#   [required]
#       COMMON_SCRIPTS_DIR      Path to directory containing common-*.sh
#
COMMON_SCRIPTS_DIR="$LOADER_DIR/scripts/bash-common-scripts"


#   [required]
#       MODULE_PATHS            Array containing one or more paths. Each path string should be one of the following:
#                                 - Directories to search for MODULE.sh definition files
#                                 - Direct paths to MODULE.sh definition files
#
MODULE_PATHS=(
    "$LOADER_DIR/modules"
    "$LOADER_DIR/modules/nxt"
)
 

#   [required]
#       LOADER_TITLE            Title text to display in the menu header.
#       LOADER_DESCRIPTION      Description of loader. May contain multiple lines.
#
LOADER_TITLE="Installer for Lego Mindstorms NXT Tools"
LOADER_DESCRIPTION=\
"The following is a collection of scripts for configuring Linux to interact with the Lego Mindstorms NXT."
 

#   [optional]
#       ****                    Define additional global variables in this section.
#                               These will be readable by all modules.
#       
PROJECT_BIN_DIR="$LOADER_DIR/bin"
PROJECT_CONFIG_DIR="$LOADER_DIR/config"
PROJECT_SCRIPTS_DIR="$LOADER_DIR/scripts"


#   [optional]
#       ARGSPEC                 Associative array in which:
#                                 ["keys"] are command-line flags (taking one positional argument after each), with
#                                 "values", which are the default values of the arguments if not specified.
#                               ARGSPEC overrides default values of __ARGS__ where both have the same keys.
#
declare -A ARGSPEC=(
    ["install"]=""
    ["force"]="false"
    ["allowroot"]="false"
    ["logfile"]="$LOADER_DIR/nxt-tools.log"
    ["prefix"]="/usr/local"
)


#   [optional]
#       ARGS_HELP_TEXT          Multiline string containing argument usage help.
#                               ARGS_HELP_TEXT overrides __DEFAULT_ARGS_HELP_TEXT__ if nonempty.
#
ARGS_HELP_TEXT=\
"--help                    Shows this help text.
--install \"module list\"   Space-separated list of module names to install.
                            Installs these modules (and their dependencies) in
                            unattended mode, suppressing all user input prompts.
                            By default, the loader skips modules which are
                            already installed (unless using --force true)
                            If left blank, displays the interactive menu.
                            Default: \"${ARGSPEC[install]}\"
--force false|true        Forces modules to reinstall even if they are already installed.
                          Continues installation even if modules fail to install.
                            Default: \"${ARGSPEC[force]}\"
--allowroot false|true    Allows the installer to run with superuser privilege.
                            If false, the installer will refuse to run with
                            superuser privilege. Modules which use 'sudo' will ask
                            for a sudo password if needed.
                            Default: \"${ARGSPEC[allowroot]}\"
--logfile \"/path/to/log\"  Specify a different log file. Log will be overwritten.
                            Default: \"${ARGSPEC[logfile]}\"
--prefix \"/install/path\"  Specify the base install path for all modules which
                            support variable install location. Typically, modules
                            will create files in PREFIX/bin, PREFIX/src, etc.
                            Default: \"${ARGSPEC[prefix]}\""


#   [optional]
#       MENU_COMMANDS           Associative array in which:
#                                 ["keys"] are user input keywords, corresponding to
#                                 "values", which are executable commands.
#                               MENU_COMMANDS overrides __MENU_COMMANDS__ where both have the same keys.
#
# declare -A MENU_COMMANDS=(
#   ["userinput"]="echo 'Command to run'"
# )


###############################################################################
#   Do not edit this section!
if ! source "$COMMON_SCRIPTS_DIR/common-installer.sh"; then
    echo "Error loading required source: $COMMON_SCRIPTS_DIR/common-installer.sh"
    echo "Please run:"
    echo "  git submodule update --init --recursive"
    echo ""
    exit 1
fi
loader_start

###############################################################################
