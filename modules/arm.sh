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
module="arm"
title="ARM Cross Compiler (arm-none-eabi)"
#
# Optional keys: May be empty or omitted entirely
#
requires=""
description=\
"The ARM EABI cross-compiler (gcc-arm-none-eabi) compiles source code into executable binaries for ARM processors, such as those found in the NXT and EV3 bricks.
It is a required component for firmware development and for some programming environments (nxOS, nxtOSEK, etc)."
author="Daniel Kennedy"
email=""
website="https://github.com/daniel-utilities/mindstorms-scripts"
hidden="false"
#
# *************************************************************************************************

exit 0

function module_check() {
    [[ -x "$(command -v gcc-arm-non-eabi)" ]];
}
