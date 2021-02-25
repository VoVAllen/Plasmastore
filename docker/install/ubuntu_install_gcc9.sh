apt install -y software-properties-common
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt update
apt install -y gcc-9
apt install -y g++-9

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 20 &&
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 20