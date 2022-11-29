
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
    if [ -x "$(command -v nexttool)" ]; then
        echo "NeXTTool is already installed."
        if [[ _AUTOCONFIRM == true ]]; then return; fi;
        if ! confirmation_prompt; then return; fi;
    fi
    local url="http://svn.code.sf.net/p/bricxcc/code/"
    local name="bricxcc"
    local tmp_dir="/tmp"
    local repo_dir="$tmp_dir/$name"
    local install_dir="/usr/local/bin"
    local original_dir="$pwd"
    echo ""
    echo "The following repository will be downloaded into $repo_dir:" 
    echo "  URL=$url"
    echo "  BRANCH=$branch"
    echo ""
    echo "Then, files will be installed to:"
    echo "  $install_cmd"
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    echo "Downloading repository: $name"
    mkdir -p "$repo_dir"
    cd "$repo_dir"
    svn checkout "$url"

    echo "Building nexttool..."
    cd "$repo_dir/code"
    make -f nexttool.mak

    echo "Installing nexttool to $install_dir..."
    sudo cp -f "$repo_dir/code/nexttool" "$install_dir/nexttool"
    sudo chown root:root "$install_dir/nexttool"
    sudo chmod a+s "$install_dir/nexttool"

    local userhome;
    get_user_home userhome
    if [ ! -d "$userhome/bricxcc" ]; then
        cp -r "$config/bricxcc" "$userhome/bricxcc"
    fi

    cd "$original_dir"
    rm -rf "$repo_dir"
}


# LIBNXT
function install_libnxt() {
    if [ ! -x "$(command -v docker)" ]; then
        echo "Could not install LibNXT (Docker not installed)."
        return 1
    fi
    if [ -x "$(command -v fwflash)" ]; then
        echo "LibNXT utilities are already installed."
        if [[ _AUTOCONFIRM == true ]]; then return; fi;
        if ! confirmation_prompt; then return; fi;
    fi
    local url="https://github.com/rvs/libnxt.git"
    local branch=master
    local name="$(basename $url)"; name="${name%.*}"
    local tmp_dir="/tmp"
    local repo_dir="$tmp_dir/$name"
    local install_dir="/usr/local/bin"
    local original_dir="$pwd"
    echo ""
    echo "The following repository will be downloaded into $repo_dir:" 
    echo "  URL=$url"
    echo "  BRANCH=$branch"
    echo ""
    echo "Then, files will be installed to:"
    echo "  $install_cmd"
    echo ""
    if ! confirmation_prompt; then return; fi;
    echo ""

    echo "Downloading repository: $name"
    cd "$tmp_dir"
    git_latest "$url" "$branch"

    echo "Building LibNXT..."
    cd "$repo_dir"
    make
    
    echo "Installing fwexec and fwflash to $install_dir..."
    sudo cp -f "$repo_dir/out/fwflash" "$install_dir/fwflash"
    sudo cp -f "$repo_dir/out/fwexec" "$install_dir/fwexec"
    cd "$install_dir"
    sudo chown root:root "./fwflash"
    sudo chmod a+s "./fwflash"
    sudo chown root:root "./fwexec"
    sudo chmod a+s "./fwexec"

    cd "$original_dir"
    rm -rf "$repo_dir"
}

