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
MTD=${CUR_DIR}/openbmc/build/tmp/deploy/images/ast2600-default/obmc-phosphor-image-ast2600-default.static.mtd

${QEMU_BUILD}/qemu-system-arm \
  -M ast2600-evb \
  -m 2048M \
  -nographic \
  -nic user \
  -drive file=${MTD},format=raw,if=mtd
