#!/usr/bin/env bash
# 
# *************************************************************************************************
# [common-sysconfig script]
# *************************************************************************************************
name="nxtosek"
longname="NXTOSEK - Real-time OS for C/C++ development on the NXT"
description="Install NXTOSEK"
longdescription=\
""
requires="usb libnxt nexttool arm"

function verify() {
    [[ -d "/opt/nxtosek" ]];
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
