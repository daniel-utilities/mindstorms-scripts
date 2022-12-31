#!/usr/bin/env bash
# 
# *************************************************************************************************
# [common-sysconfig module]
# *************************************************************************************************
module="usb"
name="Mindstorms USB Configuration"
description="Install Mindstorms USB Configuration"
longdescription=\
"UDEV rules are required for user access to hardware devices, including all Mindstorms devices. Without this configuration, all tools will require 'sudo' (root) privilege and many scripts will break.
Where applicable, kernel modules will be enabled so Mindstorms devices always have the correct drivers available."
requires=""
# *************************************************************************************************





function verify() {
    [[ -f "/etc/udev/rules.d/50-pbrick.rules" ]];
}
if [[ "$1" == "-verify-only" ]]; then verify; exit $?; fi




local -A fnargs=( ["config"]="./config" )
fast_argparse fnargs "" "config" "$@"
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

echo ""
echo "--------------------------------------------------------------------------------"
echo "                            USB Device Configuration"
echo "--------------------------------------------------------------------------------"
echo ""
echo "UDEV rules are required to access Mindstorms devices over USB."
echo "Without this, tools will not work without 'sudo' and many scripts will break."
echo ""
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
