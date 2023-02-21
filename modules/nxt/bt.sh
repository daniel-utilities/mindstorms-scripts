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
module="bt"
title="Bluetooth Device Configuration"
#
# Optional keys: May be empty or omitted entirely
#
requires=""
description="The NXT can communicate wirelessly with devices which support the Bluetooth Serial Port Profile (SPP). This device will be configured for SPP communication with NXT bricks."
author=""
email=""
website="https://github.com/daniel-utilities/mindstorms-scripts"
hidden="false"
#
# *************************************************************************************************

exit 0



function module_check() {
    return 1
}

