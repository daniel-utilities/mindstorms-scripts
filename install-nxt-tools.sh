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
__LOADER_TEMPLATE_VERSION__="1.0"
__LOADER_BASE_NAME__="$(basename -s .sh "$0")"


###############################################################################
####                         VARIABLE DEFINITIONS                          ####
###############################################################################

#   [optional]
#       ****                    Define additional global variables in this section.
#                               These will be made readable (but not writeable) by all modules.
#       
PROJECT_ROOT="$(dirname "$(readlink -f "$0")")"
PROJECT_BIN="$PROJECT_ROOT/bin"
PROJECT_CONFIG="$PROJECT_ROOT/config"
PROJECT_MODULES="$PROJECT_ROOT/modules"
PROJECT_SCRIPTS="$PROJECT_ROOT/scripts"


#   [required]
#       COMMON_SCRIPTS_PATH     Path to directory containing common-*.sh
#
COMMON_SCRIPTS_PATH="$PROJECT_SCRIPTS/bash-common-scripts"


#   [required]
#       MODULE_PATHS            Array containing one or more paths. Each path string should be one of the following:
#                                 - Directories to search for MODULE.sh definition files
#                                 - Direct paths to MODULE.sh definition files
#
MODULE_PATHS=(
    "$PROJECT_MODULES"
    "$PROJECT_MODULES/nxt"
)
 

#   [required]
#       MENU_TITLE              Title text to display in the menu header.
#       MENU_DESCRIPTION        Description of loader. May contain multiple lines.
#       MENU_PROMPT             User input prompt. May contain multiple lines.
#
MENU_TITLE="Installer for Lego Mindstorms NXT Tools"
MENU_DESCRIPTION=\
"The following is a collection of scripts for configuring Linux to interact with the Lego Mindstorms NXT.
> Enter a module name to learn more. The system will not be modified without your permission.
> Enter 'help' to list all valid internal commands.
> Press CTRL+C to abort the script at any time."
MENU_PROMPT="Enter module names or commands, or type 'x' to exit:"
 

#   [optional]
#       CUSTOM_MENU_COMMANDS    Associative array in which:
#                                 ["keys"] are user input keywords, corresponding to
#                                 "values", which are executable commands.
#                               CUSTOM_MENU_COMMANDS overrides __DEFAULT_MENU_COMMANDS__ where both have the same keys.
#
declare -A CUSTOM_MENU_COMMANDS=(
)


#   [optional]
#       CUSTOM_ARGS             Associative array in which:
#                                 ["keys"] are command-line flags (taking one positional argument after each), with
#                                 "values", which are the default values of the arguments if not specified.
#                               CUSTOM_ARGS overrides __DEFAULT_ARGS__ where both have the same keys.
#
declare -A CUSTOM_ARGS=(
    ["install"]=""
    ["force"]="false"
    ["allowroot"]="false"
    ["logfile"]="$PROJECT_ROOT/nxt-tools.log"
    ["prefix"]="/usr/local"
)


#   [optional]
#       CUSTOM_ARGS_HELP_TEXT   Multiline string containing argument usage help.
#
CUSTOM_ARGS_HELP_TEXT=\
"--help                    Shows this help text.
--install \"module list\"   Space-separated list of module names to install.
                            Installs these modules (and their dependencies) in
                            unattended mode, suppressing all user input prompts.
                            By default, the loader skips modules which are
                            already installed (unless using --force true)
                            If left blank, displays the interactive menu.
                            Default: \"${CUSTOM_ARGS[install]}\"
--force false|true        Forces modules to install even if they are already installed.
                            Default: \"${CUSTOM_ARGS[force]}\"
--allowroot false|true    Allows the installer to run with superuser privilege.
                            If false, the installer will refuse to run with
                            superuser privilege. Modules which use 'sudo' will ask
                            for a sudo password if needed.
                            Default: \"${CUSTOM_ARGS[allowroot]}\"
--logfile \"/path/to/log\"  Specify a different log file. Log will be overwritten.
                            Default: \"${CUSTOM_ARGS[logfile]}\"
--prefix \"/install/path\"  Specify the base install path for all modules which
                            support variable install location. Typically, modules
                            will create files in PREFIX/bin, PREFIX/src, etc.
                            Default: \"${CUSTOM_ARGS[prefix]}\""


###############################################################################
#   Do not edit this section!
source "$COMMON_SCRIPTS_PATH/common-installer.sh"
if [[ "$?" -ne 0 ]]; then
    echo "Error loading required source: $COMMON_SCRIPTS_PATH/common-installer.sh"
    echo "Please run:"
    echo "  git submodule update --init --recursive"
    echo ""
    exit 1
fi
loader_start "$@"

###############################################################################
