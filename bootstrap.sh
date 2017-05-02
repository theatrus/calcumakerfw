#!/bin/bash

set -e

GCC_VERSION=6-2017-q1-update
GMP_VERSION=6.1.2
MPFR_VERSION=3.1.5
MPC_VERSION=1.0.3


rm -rf buildtmp
rm -rf extlib

mkdir -p buildtmp
mkdir -p extlib

EXTLIB=$PWD/extlib

pushd .
cd buildtmp
wget https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.gz
wget http://www.mpfr.org/mpfr-current/mpfr-${MPFR_VERSION}.tar.gz
wget http://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/6_1-2017q1/gcc-arm-none-eabi-${GCC_VERSION}-linux.tar.bz2

tar xvjf gcc-arm-none-eabi-${GCC_VERSION}-linux.tar.bz2
tar xvzf gmp-${GMP_VERSION}.tar.gz
tar xvzf mpfr-${MPFR_VERSION}.tar.gz
tar xvzf mpc-${MPC_VERSION}.tar.gz

export PATH=$PATH:$PWD/gcc-arm-none-eabi-${GCC_VERSION}

pushd .
cd gmp-${GMP_VERSION}
./configure CC=arm-none-eabi-gcc CFLAGS="-I$HOME/gmprot/include -nostartfiles --specs=nosys.specs -mcpu=cortex-m4 -Os" LDFLAGS="-L$HOME/gmprot" --host=arm-none-eabi --disable-assembly --prefix=$EXTLIB --disable-shared
make -j 4
make install
popd

pushd .
cd mpfr-${MPFR_VERSION}
./configure CC=arm-none-eabi-gcc CFLAGS="-I$HOME/gmprot/include -nostartfiles --specs=nosys.specs -mcpu=cortex-m4 -Os" LDFLAGS="-L$HOME/gmprot" --host=arm-none-eabi --disable-assembly --prefix=$EXTLIB --disable-shared --with-gmp=${EXTLIB}
make -j 4
make install
popd
