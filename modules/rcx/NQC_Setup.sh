parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P ) && cd "$parent_path"

echo 'Installing NQC programming language.'
read -p 'Enter your username: ' u
mkdir /home/$u/nqc-3.1.r6
cp bin/nqc-01-Linux_usb_and_tcp.diff /home/$u/nqc-01-Linux_usb_and_tcp.diff
cp bin/nqc-3.1.r6.tgz /home/$u/nqc-3.1.r6
cd /home/$u/nqc-3.1.r6
tar xfz nqc-3.1.r6.tgz
sed -i '1s/^/#include <unistd.h> \n/' compiler/lexer.cpp
cd ..
patch -p0 < nqc-01-Linux_usb_and_tcp.diff
rm nqc-01-Linux_usb_and_tcp.diff
cd nqc-3.1.r6
make
sudo make install

echo
echo 'NQC should now be installed (hopefully).'
echo 'Download program:'
echo '    nqc -Susb:/dev/usb/legousbtower1 -d helloworld.nqc'
echo 'Run program:'
echo '    nqc -Susb:/dev/usb/legousbtower1 -run'
echo 'Display help:'
echo '    nqc -help'
