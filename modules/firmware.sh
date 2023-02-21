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
module="firmware"
title="Lego Mindstorms Firmware Package"
#
# Optional keys: May be empty or omitted entirely
#
requires=""
description=\
"This script installs a variety of Mindstorms firmware to the system so it is accessible for all users. Both official Lego firmware and unofficial 3rd-party binaries are included.
See the README in the install directory for details."
author=""
email=""
website="https://github.com/daniel-utilities/mindstorms-scripts"
hidden="false"
#
# *************************************************************************************************


exit 0

function module_check() {
    [[ -d "/usr/local/etc/mindstorms/firmware" ]];
}
