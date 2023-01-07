#!/usr/bin/env bash
# 
# *************************************************************************************************
# [common-installer module]
# *************************************************************************************************
module="libnxt"
name="LibNXT"
description="Install LibNXT"
longdescription=\
"LibNXT provides a linkable binary and C headers for developing software which communicates with the NXT brick using libusb.
It also provides two command-line utilities which are required components of some toolchains:
 -  fwflash: Downloads firmware to an NXT brick.
 -  fwexec:  Runs a specially-compiled binary directly in the NXT's RAM."
requires="usb"

function verify() {
    [[ -x "$(command -v fwflash)" && -x "$(command -v fwexec)" ]];
}
if [[ "$1" == "--verify-only" ]]; then verify; exit $?; fi
# *************************************************************************************************



local -A fnargs=( ["config"]="./config" 
                    ["install"]="/usr/local/bin" )
fast_argparse fnargs "" "config install" "$@"
local config_dir="${fnargs[config]}"
local install_dir="${fnargs[install]}"
local original_dir="$pwd"

local -a packages=(
    git gcc g++ build-essential libusb-1.0-0-dev meson gcc-arm-none-eabi scdoc python3
)

local url="https://github.com/schodet/libnxt.git"
local branch=master
local repo="$(basename $url .git)"
local repo_dir="/tmp/$repo"

local -a install_files=(
    "$repo_dir/build/fwflash      :  $install_dir/fwflash"
    "$repo_dir/build/fwexec       :  $install_dir/fwexec"
    "$repo_dir/build/liblibnxt.a  :  /usr/local/lib/liblibnxt.a"
    "$repo_dir/error.h            :  /usr/local/include/libnxt/error.h"
    "$repo_dir/firmware.h         :  /usr/local/include/libnxt/firmware.h"
    "$repo_dir/flash.h            :  /usr/local/include/libnxt/flash.h"
    "$repo_dir/lowlevel.h         :  /usr/local/include/libnxt/lowlevel.h"
    "$repo_dir/samba.h            :  /usr/local/include/libnxt/samba.h"
    "$repo_dir/build/flash_routine.h  :  /usr/local/include/libnxt/flash_routine.h"
    "$repo_dir/build/flash_write/crt0.o  :  /usr/local/include/libnxt/flash_write/crt0.o"
    "$repo_dir/build/flash_write/flash.bin  :  /usr/local/include/libnxt/flash_write/flash.bin"
    "$repo_dir/build/flash_write/flash.elf  :  /usr/local/include/libnxt/flash_write/flash.elf"
    "$repo_dir/build/flash_write/flash.o  :  /usr/local/include/libnxt/flash_write/flash.o"
    "$repo_dir/error.c               :  /usr/local/src/libnxt/error.c"
    "$repo_dir/firmware.c            :  /usr/local/src/libnxt/firmware.c"
    "$repo_dir/flash.c               :  /usr/local/src/libnxt/flash.c"
    "$repo_dir/lowlevel.c            :  /usr/local/src/libnxt/lowlevel.c"
    "$repo_dir/samba.c               :  /usr/local/src/libnxt/samba.c"
    "$repo_dir/main_fwexec.c         :  /usr/local/src/libnxt/main_fwexec.c"
    "$repo_dir/main_fwflash.c        :  /usr/local/src/libnxt/main_fwflash.c"
    "$repo_dir/make_flash_header.py  :  /usr/local/src/libnxt/make_flash_header.py"
    "$repo_dir/flash_write/flash.c   :  /usr/local/src/libnxt/flash_write/flash.c"
    "$repo_dir/flash_write/crt0.s    :  /usr/local/src/libnxt/flash_write/crt0.s"
)

echo ""
echo "--------------------------------------------------------------------------------"
echo "                                   LibNXT"
echo "--------------------------------------------------------------------------------"
echo ""
echo "LibNXT is a set of command-line utilities for communicating with the NXT brick."
echo "  fwflash: downloads firmware to the brick."
echo "  fwexec:  runs a specially-compiled code directly in RAM."
echo "It also provides C headers for developing software which talks to the brick."
echo ""
if [ -x "$(command -v fwflash)" ]; then
    echo "LibNXT is already installed."
    if ! confirmation_prompt "Continue anyway?"; then return 0; fi
    echo ""
fi
echo "The following APT packages will be installed:" 
echo "  ${packages[@]}"
echo ""
echo "The following repository will be downloaded:" 
echo "  URL:    $url"
echo "  Branch: $branch"
echo "  Path:   $repo_dir"
echo ""
echo "The following files will be installed:" 
print_var install_files -showname false -wrapper ""
echo ""
if ! confirmation_prompt; then return 0; fi
echo ""

echo ""
echo "Downloading repository: $repo"
cd "/tmp"
git_latest "$url" "$branch"

echo ""
echo "Building LibNXT..."
cd "$repo_dir"
meson build
cd build
meson compile

echo ""
echo "Installing files..."
sudo mkdir -p "/usr/local/include/libnxt" 2>&1 > /dev/null
sudo mkdir -p "/usr/local/include/libnxt/flash_write" 2>&1 > /dev/null
sudo mkdir -p "/usr/local/src/libnxt" 2>&1 > /dev/null
sudo mkdir -p "/usr/local/src/libnxt/flash_write" 2>&1 > /dev/null
multicopy install_files
sudo chmod +x "$install_dir/fwflash"
sudo chmod +x "$install_dir/fwexec"

echo ""
echo "Cleaning up..."
#rm -rf "$repo_dir"
cd "$original_dir"

echo ""
echo "Installation complete."
pause
