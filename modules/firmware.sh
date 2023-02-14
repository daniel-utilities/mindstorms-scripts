#!/usr/bin/env bash
# 
# *************************************************************************************************
# [common-installer module]
# *************************************************************************************************
module="firmware"
description="Lego Mindstorms Firmware Package"
title="Install Mindstorms Firmware"
longdescription=\
"This script installs a variety of Mindstorms firmware to the system so it is accessible for all users. Both official Lego firmware and unofficial 3rd-party binaries are included.
See the README in the install directory for details."
requires=""

function verify() {
    [[ -d "/usr/local/etc/mindstorms/firmware" ]];
}
if [[ "$1" == "--verify-only" ]]; then verify; exit $?; fi
# *************************************************************************************************



local -A fnargs=( ["config"]="./config" 
                    ["install"]="/usr/local/bin" )
fast_argparse fnargs "" "config install" "$@"
local config_dir="${fnargs[config]}"
local install_dir="${fnargs[install]}"
local original_dir="$pwd"
local userhome; get_user_home userhome
