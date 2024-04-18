#!/bin/bash

SHELL_NAME=$(basename "$SHELL")

if [ "$SHELL_NAME" = "bash" ]; then
    CUR_DIR=$(pwd)
elif [ "$SHELL_NAME" = "zsh" ]; then
    CUR_DIR=$(pwd -P)
else
    exit 1
fi

BUSYBOX_TOP=${CUR_DIR}/busybox

cd ${BUSYBOX_TOP}

git clean -xdf

make -j`nproc` ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- defconfig

sed -i '/CONFIG_STATIC is not set/s/.*/CONFIG_STATIC=y/' ./.config

make -j`nproc` ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

make -j`nproc` ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- install

cd ./_install

mkdir etc dev lib
mkdir etc/init.d

sh -c 'cat << EOF >> etc/profile
#!/bin/sh
export HOSTNAME=bryant
export USER=root
export HOME=/home
export PS1="[$USER@$HOSTNAME \W]\# "
PATH=/bin:/sbin:/usr/bin:/usr/sbin
LD_LIBRARY_PATH=/lib:/usr/lib:$LD_LIBRARY_PATH
export PATH LD_LIBRARY_PATH
EOF'

sh -c 'cat << EOF >> etc/inittab
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::askfirst:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF'

sh -c 'cat << EOF >> etc/fstab
#device  mount-point    type     options   dump   fsck order
proc /proc proc defaults 0 0
tmpfs /tmp tmpfs defaults 0 0
sysfs /sys sysfs defaults 0 0
tmpfs /dev tmpfs defaults 0 0
debugfs /sys/kernel/debug debugfs defaults 0 0
kmod_mount /mnt 9p trans=virtio 0 0
EOF'


sh -c 'cat << EOF >> init.d/rcS
mkdir -p /sys
mkdir -p /tmp
mkdir -p /proc
mkdir -p /mnt
/bin/mount -a
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
EOF'
