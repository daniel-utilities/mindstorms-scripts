#!/usr/bin/env bash
# 
# *************************************************************************************************
# [common-installer script]
# *************************************************************************************************
module="arm"
name="ARM EABI Cross Compiler"
description="Install ARM EABI Compiler"
longdescription=\
"The ARM EABI cross-compiler (gcc-arm-none-eabi) compiles source code into executable binaries for ARM processors, such as those found in the NXT and EV3 bricks.
It is a required component for firmware development and for some programming environments (nxOS, nxtOSEK, etc)."
requires="usb"

function verify() {
    [[ -x "$(command -v gcc-arm-non-eabi)" ]];
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
