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

if [ -d "${QEMU_BUILD}" ]; then
    rm -rf "${QEMU_BUILD}"
fi

mkdir -p ${QEMU_BUILD} && cd ${QEMU_BUILD}
../configure \
    --target-list=arm-softmmu \
    --enable-debug-tcg \
    --enable-debug \
    --enable-debug-info \
    -enable-trace-backends=log \
    --enable-slirp
make -j`nproc`
