#!/usr/bin/env bash
# 
# *************************************************************************************************
# [common-installer module]
# *************************************************************************************************
module="bt"
name="Bluetooth Device Configuration"
description="Install Bluetooth Support for Mindstorms NXT"
longdescription=\
"The NXT can communicate wirelessly with devices which support the Bluetooth Serial Port Profile (SPP). This device will be configured for SPP communication with NXT bricks."
requires=""

function verify() {
    return 1
}
if [[ "$1" == "--verify-only" ]]; then verify; exit $?; fi
# *************************************************************************************************


local -A args=( ["config"]="./config" )
fast_argparse args "" "config" "$@"
local config_dir="${args[config]}"

echo ""
echo "--------------------------------------------------------------------------------"
echo "                      Bluetooth Device Configuration"
echo "--------------------------------------------------------------------------------"
echo ""
echo "The NXT can communicate wirelessly with devices which support the"
echo "Bluetooth \"Classic\" Serial Port Profile (SPP)."
echo ""
echo "Automated installation is not currently implemented."
echo "Please visit the following link for manual installation instructions:"
echo "https://gist.github.com/gmsanchez/3787079f29f0b3f9a2f47c08c59b58b5"
echo ""

echo ""
echo "Installation complete."
pause
