#!/bin/bash

set -e
set -x

GCC_VERSION=6-2017-q1-update
GMP_VERSION=6.1.2
MPFR_VERSION=3.1.5
MPC_VERSION=1.0.3

export CC=arm-none-eabi-gcc
export CFLAGS="-nostartfiles --specs=nosys.specs -mcpu=cortex-m4 -Os -mfloat-abi=hard -mfpu=fpv4-sp-d16"

rm -rf extlib

mkdir -p buildtmp
mkdir -p extlib

EXTLIB=$PWD/extlib

pushd .
cd buildtmp
if [ ! -f gmp-${GMP_VERSION}.tar.bz2 ]; then
    wget https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.bz2
fi

if [ ! -f mpfr-${MPFR_VERSION}.tar.gz ]; then
    wget http://www.mpfr.org/mpfr-current/mpfr-${MPFR_VERSION}.tar.gz
fi

if [ ! -f mpc-${MPC_VERSION}.tar.gz ]; then
    wget http://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz
fi

if [ ! -f gcc-arm-none-eabi-${GCC_VERSION}-linux.tar.bz2 ]; then
    wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/6_1-2017q1/gcc-arm-none-eabi-${GCC_VERSION}-linux.tar.bz2
fi

if [ ! -d gcc-arm-none-eabi-${GCC_VERSION} ]; then
    rm -rf gcc-arm-none-eabi-${GCC_VERSION}
    tar xjf gcc-arm-none-eabi-${GCC_VERSION}-linux.tar.bz2
fi

rm -rf gmp-${GMP_VERSION}
tar xjf gmp-${GMP_VERSION}.tar.bz2
rm -rf mpfr-${MPFR_VERSIO}
tar xzf mpfr-${MPFR_VERSION}.tar.gz
tar xzf mpc-${MPC_VERSION}.tar.gz

export PATH=$PATH:$PWD/gcc-arm-none-eabi-${GCC_VERSION}/bin

pushd .
cd gmp-${GMP_VERSION}
./configure  --host=arm-none-eabi --disable-assembly --prefix=$EXTLIB --disable-shared
make -j 4
make install
popd

pushd .
cd mpfr-${MPFR_VERSION}
./configure --host=arm-none-eabi --disable-assembly --prefix=$EXTLIB --disable-shared --with-gmp=${EXTLIB}
make -j 4
make install
popd
