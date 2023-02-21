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
module="nxtosek"
title="NXT-OSEK Development Tools"
#
# Optional keys: May be empty or omitted entirely
#
requires="usb libnxt nexttool arm"
description="NXT-OSEK is a Real-time Operating System (RTOS) kernel for the Mindstorms NXT. This module installs the necessary source code and C/C++ development toolchain for working with NXT-OSEK."
author="Takashi Chikamasa et. al."
email=""
website="https://lejos-osek.sourceforge.net/whatislejososek.htm"
hidden="false"
#
# *************************************************************************************************

exit 0

function module_check() {
    [[ -d "/opt/nxtosek" ]];
}
