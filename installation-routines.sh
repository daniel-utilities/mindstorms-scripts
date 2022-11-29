
# PREREQUISITES
function install_prerequisites() {
    local -a packages=(
        git subversion gcc g++ build-essential fpc libusb-0.1-4 libusb-dev python3
    )
    echo ""
    echo "The following APT packages will be installed:" 
    echo "  ${packages[@]}"
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    echo "Installing prerequisites..."
    sudo apt-get update
    sudo apt-get install -y ${packages[@]}
}


# UDEV
function install_udev_rules_nxt() {
    local -a install_files=(
        "$config_dir/udev/70-nxt.rules         : /etc/udev/rules.d/70-nxt.rules"
        "$config_dir/udev/nxt_event_handler.sh : /etc/udev/nxt_event_handler.sh"
    )
    local -a permgroups=(
        plugdev
        dialout
        users
    )
    echo ""
    echo "UDEV rules are required to access NXT/SAM-BA devices over USB."
    echo "Without this, NXT tools will not work without 'sudo' and many scripts may break."
    echo ""
    echo "The following files will be installed:" 
    print_arr install_files
    echo ""
    echo "The user $USER will be added to the following groups:"
    print_arr permgroups
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    echo "Installing UDEV rules..."
    multicopy install_files

    echo "Adding $USER to groups..."
    for groupname in ${permgroups[@]}; do
        sudo groupadd -f $groupname
        sudo usermod -aG $groupname $USER
    done

    echo "Reloading UDEV..."
    sudo udevadm control --reload-rules && sudo udevadm trigger
}


# NEXTTOOL
function install_nexttool() {
    local install_dir="/usr/local/bin"
    echo "Downloading repository: http://svn.code.sf.net/p/bricxcc/code/"
    mkdir -p "$SRC_DIR/bricxcc"
    cd "$SRC_DIR/bricxcc"
    svn checkout http://svn.code.sf.net/p/bricxcc/code/

    echo "Building nexttool..."
    cd "$SRC_DIR/bricxcc/code"
    make -f nexttool.mak
    sudo cp -f "./nexttool" "$install_dir/nexttool"

    echo "Installing nexttool to $install_dir..."
    cd "$install_dir"
    sudo chown root:root "./nexttool"
    sudo chmod a+s "./nexttool"

    if [ ! -d "/home/$USER/bricxcc" ]; then
        cp -r "$CONFIG_DIR/bricxcc" "/home/$USER/bricxcc"
    fi
}


# LIBNXT
function install_libnxt() {
    if [ ! -x "$(command -v docker)" ]; then
        echo "Could not install LibNXT (Docker not installed)."
        return 1
    fi
    local install_dir="/usr/local/bin"
    echo "Downloading repository: https://github.com/rvs/libnxt.git"
    cd "$SRC_DIR"
    if [ ! -d "./libnxt" ]; then
        git clone https://github.com/rvs/libnxt.git
    else
        cd "./libnxt"
        git pull origin master
    fi

    echo "Building LibNXT..."
    cd "$SRC_DIR/libnxt"
    make
    
    echo "Installing fwexec and fwflash to $install_dir..."
    cd "$SRC_DIR/libnxt/out"
    sudo cp -f "./fwflash" "$install_dir/fwflash"
    sudo cp -f "./fwexec" "$install_dir/fwexec"
    cd "$install_dir"
    sudo chown root:root "./fwflash"
    sudo chmod a+s "./fwflash"
    sudo chown root:root "./fwexec"
    sudo chmod a+s "./fwexec"
}

