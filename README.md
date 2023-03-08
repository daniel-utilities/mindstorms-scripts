# mindstorms-scripts
Scripts for installing and managing Lego Mindstorms devices on Linux.

## Installation
Clone this repo to your system *with submodules*.
```
git clone --recurse-submodules https://github.com/daniel-utilities/mindstorms-scripts.git
```
If you cloned the repository without --recurse-submodules, you'll need to run the following from the root directory of the repository:
```
git submodule update --init --recursive
```
Then run one of the installation scripts:
```
chmod +x install-nxt-tools.sh
install-nxt-tools.sh
```
