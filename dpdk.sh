#!/bin/sh

set -e

# Initialize dpdk module
git submodule init
git submodule update --recursive

# Apply driver patches
patch -p 1 -d dpdk/ < ixgbe_19_11.patch


if lspci | grep -q 'ConnectX-5'; then
   patch -p 1 -d dpdk/ < mlx5_19_11.patch
elif lspci | grep -q 'ConnectX-3'; then
    patch -p 1 -d dpdk/ < mlx4_19_11.patch
    sed -i 's/CONFIG_RTE_LIBRTE_MLX4_PMD=n/CONFIG_RTE_LIBRTE_MLX4_PMD=y/g' dpdk/config/common_base
fi

patch -p1 -N -d dpdk/ < linux_5_14_gcc_9_4.patch

# Configure/compile dpdk
make -C dpdk/ config T=x86_64-native-linuxapp-gcc
make -C dpdk/ -j
