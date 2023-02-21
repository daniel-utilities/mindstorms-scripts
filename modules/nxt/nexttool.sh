#!/usr/bin/env bash

# *************************************************************************************************
# [common-installer module]
# *************************************************************************************************
#
# Required identifier; does not need to be set to anything
#
__COMMON_INSTALLER_MODULE__=
#
# Required keys: Must be nonempty
#
module="nexttool"
title="NeXTTool Utility (nexttool)"
#
# Optional keys: May be empty or omitted entirely
#
requires="usb"
description="NeXTTool is a command-line utility for interacting with the NXT brick. It is primarily used to download files and firmware to the NXT brick, but also provides various monitoring and remote-control functionality (when used with firmware variants based on the official Lego distributions). It is a required component of some toolchains (MATLAB RWTH, nxtOSEK, etc)."
author="John Hansen"
email=""
website="https://bricxcc.sourceforge.net/"
hidden="false"
#
# *************************************************************************************************

exit 0

function module_check() {
    [[ -x "$(command -v nexttool)" ]];
}





local __PROJECT_CONFIG__="${fnargs[config]}"
local install_dir="${fnargs[install]}"
local original_dir="$pwd"
local userhome; get_user_home userhome

local -a packages=(
    subversion gcc g++ build-essential libusb-dev libusb-0.1-4 fpc
)

local repo="bricxcc"
local url="http://svn.code.sf.net/p/bricxcc/code/"
local repo_dir="/tmp/$repo"
local install_dir="/usr/local/bin"

local -a install_files=(
    "$repo_dir/code/nexttool        : $install_dir/nexttool"
    "$__PROJECT_CONFIG__/bricxcc/bricks.dat : $userhome/bricxcc/bricks.dat"
)
echo ""
echo "--------------------------------------------------------------------------------"
echo "                                   NeXTTool"
echo "--------------------------------------------------------------------------------"
echo ""
echo "NeXTTool is a command-line utility for interacting with the NXT brick."
echo "The tool downloads programs and firmware to the Brick and offers remote-"
echo "control functionality when using firmware based on original Lego variants."
echo "It is a required component of some toolchains (MATLAB RWTH, nxtOSEK)."
echo ""
if [ -x "$(command -v nexttool)" ]; then
    echo "NeXTTool is already installed."
    if ! confirmation_prompt "Continue anyway?"; then return 0; fi
    echo ""
fi
echo "The following APT packages will be installed:" 
echo "  ${packages[@]}"
echo ""
echo ""
echo "The following SVN repository will be downloaded:" 
echo "  URL:  $url"
echo "  Path: $repo_dir"
echo ""
echo "The following files will be installed:" 
print_var install_files -showname false -wrapper ""
echo ""
if ! confirmation_prompt; then return 0; fi
echo ""

echo ""
echo "Installing packages..."
sudo apt-get update
sudo apt-get install -y ${packages[@]}

echo ""
echo "Downloading repository: $repo"
if [[ -d "$repo_dir" ]]; then rm -rf "$repo_dir"; fi
mkdir -p "$repo_dir"
cd "$repo_dir"
svn checkout "$url"

echo ""
echo "Building nexttool..."
cd "$repo_dir/code"
make -f nexttool.mak

echo ""
echo "Installing files..."
sudo cp -f "$repo_dir/code/nexttool" "$install_dir/nexttool"
sudo chmod +x "$install_dir/nexttool"
cp -rnv "$__PROJECT_CONFIG__/bricxcc" "$userhome/bricxcc"

echo ""
echo "Cleaning up..."
#rm -rf "$repo_dir"
cd "$original_dir"

echo ""
echo "Installation complete."
pause
