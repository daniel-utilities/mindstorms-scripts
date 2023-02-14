#!/usr/bin/env bash
# 
# *************************************************************************************************
# [common-installer module]
# *************************************************************************************************
module="usb"
description="Mindstorms USB Configuration"
title="Install Mindstorms USB Configuration"
longdescription=\
"UDEV rules are required for user access to hardware devices, including all Mindstorms devices. Without this configuration, all tools will require 'sudo' (root) privilege and many scripts will break.
Where applicable, kernel modules will be enabled so Mindstorms devices always have the correct drivers available."
requires=""
hidden="false"
# *************************************************************************************************


#   # Default System paths
#   args["global_bin"]="/usr/local/bin"     # Executable binaries
#   args["global_lib"]="/usr/local/lib"     # Precompiled sources (.a, .so)
#   args["global_src"]="/usr/local/src"     # Source code
#   args["global_inc"]="/usr/local/include" # Headers
#   args["global_etc"]="/usr/local/etc"     # Config files, etc.
#   args["opt"]="/opt"                      # Large "features"; ROS, Java, etc.

#   # Default Local (user-specific) paths
#   args["local_bin"]="$HOME/.local/bin"
#   args["local_lib"]="$HOME/.local/lib"
#   args["local_src"]="$HOME/.local/src"
#   args["local_inc"]="$HOME/.local/include"
#   args["local_etc"]="$HOME/.local/etc"


function verify() {
    [[ -f "/etc/udev/rules.d/50-pbrick.rules" ]];
}


# Default Project Paths
declare -A proj=()
proj["root"]="$PWD"
proj["work"]="$PWD"
proj["bin"]="${proj[root]}/bin"
proj["config"]="${proj[root]}/config"
proj["scripts"]="${proj[root]}/scripts"

# Parse Args (first pass)
case "$1" in
    "-verify-only" )  verify ;;
    "-scripts" )      proj["scripts"]="$2" ;;
esac

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

# Default Arg Values
declare -A args; copy_array proj args
args["confirm"]="true"
args["user"]="root"
args["installpath"]="/usr/local"

# Parse Args (second pass)
printf -v paramlist "%s " "${!args[@]}"
fast_argparse args "" "$paramlist" "$@"
printf "Module: [%s]\n" "$module"
printf "  - Requires:\n" "$requires"
printf "  - Params:\n"
print_var args -showname "false"

# Display UI
get_term_width terminal_width
(( titlebox_width = "${#title}" + 4 ))
get_title_box titlebox "$title" -width "$titlebox_width" -top '#' -side '#' -corner '#'
printf "\n%s\n" "$titlebox"
wrap_string wrapped_description "$longdescription" "$terminal_width"
printf "%s\n" "$wrapped_description"

exit 0




local config_dir="${fnargs[config]}"

local url="https://github.com/daniel-contrib/pbrick-rules.git"
local branch=main
local repo="$(basename $url .git)"
local repo_dir="/tmp/$repo"

local -a install_files=(
    "$repo_dir/debian/pbrick-rules.pbrick.udev : /etc/udev/rules.d/50-pbrick.rules"
    "$config_dir/udev/70-nxt.rules         : /etc/udev/rules.d/70-nxt.rules"
    "$config_dir/udev/nxt_event_handler.sh : /etc/udev/nxt_event_handler.sh"
)
local -a permgroups=(
    plugdev dialout users
)

echo "The following repository will be downloaded:" 
echo "  URL:    $url"
echo "  Branch: $branch"
echo "  Path:   $repo_dir"
echo ""
echo "The following files will be installed:" 
print_var install_files -showname false -wrapper ""
echo ""
echo "User '$USER' will be added to the following groups:"
echo "  ${permgroups[@]}"
echo ""
if ! confirmation_prompt; then return 0; fi
echo ""

echo ""
echo "Downloading repository: $repo"
cd "/tmp"
git_latest "$url" "$branch"

echo ""
echo "Installing UDEV rules..."
multicopy install_files

echo ""
for groupname in ${permgroups[@]}; do
    echo "Adding $USER to group $groupname..."
    sudo groupadd -f $groupname
    sudo usermod -aG $groupname $USER
done

echo ""
echo "Reloading UDEV rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ""
echo "Installation complete."
pause
