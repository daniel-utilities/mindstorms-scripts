
##################################################################################
#                             USB Configuration for NXT
##################################################################################
function install_nxt_usb() {
    local -A fnargs=( ["config"]="./config" )
    fast_argparse fnargs "" "config" "$@"
    local config_dir="${fnargs[config]}"

    local -a install_files=(
        "$config_dir/udev/70-nxt.rules         : /etc/udev/rules.d/70-nxt.rules"
        "$config_dir/udev/nxt_event_handler.sh : /etc/udev/nxt_event_handler.sh"
    )
    local -a permgroups=(
        plugdev dialout users
    )

    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "                            USB Configuration for NXT"
    echo "--------------------------------------------------------------------------------"
    echo ""
    echo "UDEV rules are required to access NXT and SAM-BA devices over USB."
    echo "Without this, tools will not work without 'sudo' and many scripts will break."
    echo ""
    echo "The following files will be installed:" 
    print_var install_files -showname false -wrapper ""
    echo ""
    echo "User $USER will be added to the following groups:"
    echo "  ${permgroups[@]}"
    echo ""
    if ! confirmation_prompt; then return 0; fi
    echo ""

    echo ""
    echo "Installing UDEV rules..."
    multicopy install_files

    echo ""
    for groupname in ${permgroups[@]}; do
        echo "Adding $USER to group $groupname..."
        sudo groupadd -f $groupname
        sudo usermod -aG $groupname $USER
    done

    echo ""
    echo "Reloading UDEV rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    echo ""
    echo "Installation complete."
    pause
}



##################################################################################
#                             Bluetooth Configuration for NXT
##################################################################################
function install_nxt_bluetooth() {
    local -A fnargs=( ["config"]="./config" )
    fast_argparse fnargs "" "config" "$@"
    local config_dir="${fnargs[config]}"

    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "                      Bluetooth Configuration for NXT"
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
}



##################################################################################
#                                   NeXTTool
##################################################################################
function install_nexttool() {
    local -A fnargs=( ["config"]="./config" 
                      ["install"]="/usr/local/bin" )
    fast_argparse fnargs "" "config install" "$@"
    local config_dir="${fnargs[config]}"
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
        "$config_dir/bricxcc/bricks.dat : $userhome/bricxcc/bricks.dat"
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
    cp -rnv "$config_dir/bricxcc" "$userhome/bricxcc"

    echo ""
    echo "Cleaning up..."
    #rm -rf "$repo_dir"
    cd "$original_dir"

    echo ""
    echo "Installation complete."
    pause
}



##################################################################################
#                                   LibNXT
##################################################################################
function install_libnxt() {
    local -A fnargs=( ["config"]="./config" 
                      ["install"]="/usr/local/bin" )
    fast_argparse fnargs "" "config install" "$@"
    local config_dir="${fnargs[config]}"
    local install_dir="${fnargs[install]}"
    local original_dir="$pwd"

    local -a packages=(
        git gcc g++ build-essential libusb-1.0-0-dev meson gcc-arm-none-eabi scdoc
        python3
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
}

