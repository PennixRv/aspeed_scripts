#!/bin/bash

SHELL_NAME=$(basename "$SHELL")

if [ "$SHELL_NAME" = "bash" ]; then
    CUR_DIR=$(pwd)
elif [ "$SHELL_NAME" = "zsh" ]; then
    CUR_DIR=$(pwd -P)
else
    exit 1
fi

QEMU_TOP=${CUR_DIR}/qemu
QEMU_BUILD=${QEMU_TOP}/arm_output
KERNEL=${CUR_DIR}/linux/arch/arm/boot/zImage
DTB=${CUR_DIR}/linux/arch/arm/boot/dts/aspeed/aspeed-ast2600-evb.dtb

GDB=

if [ $# == 1 ] && [ $1 == "gdb" ]
then
    GDB+="-gdb tcp::4567 -S"
fi

${QEMU_BUILD}/qemu-system-arm \
  -M ast2600-evb \
  -m 2048M \
  -nographic \
  -nic user \
  -dtb ${DTB} \
  -append "console=ttyS4,115200n8" \
  -initrd ./rootfs.cpio.xz \
  -kernel ${KERNEL} ${GDB}

