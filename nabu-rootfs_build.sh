#!/bin/bash
set -e

VERSION="23.10"

mkdir -p rootdir

wget https://cdimage.ubuntu.com/ubuntu-base/releases/$VERSION/release/ubuntu-base-$VERSION-base-arm64.tar.gz
sudo tar xzvf ubuntu-base-$VERSION-base-arm64.tar.gz -C rootdir

# copy qemu
sudo cp /usr/bin/qemu-aarch64-static rootdir/usr/bin/

# prepare minimal chroot env
sudo chroot rootdir apt update
sudo chroot rootdir apt install -y sudo bash-completion ssh nano

# install device specific stuff
sudo chroot rootdir apt install -y rmtfs protection-domain-mapper tqftpserv

# install kernel debs
sudo cp xiaomi-nabu-debs_$2/*.deb rootdir/tmp/
sudo chroot rootdir dpkg -i /tmp/*.deb || true
sudo chroot rootdir apt --fix-broken install -y
sudo rm rootdir/tmp/*.deb

# setup fstab
echo "PARTLABEL=linux / ext4 errors=remount-ro,x-systemd.growfs 0 1
PARTLABEL=esp /boot/efi vfat umask=0077 0 1" | sudo tee rootdir/etc/fstab

# clean
sudo chroot rootdir apt clean

# compress
7zz a rootfs.7z rootdir
