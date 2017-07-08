#!/bin/bash

set -e
set -x

GCC_VERSION=6-2017-q1-update

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    GCC_OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    GCC_OS="mac"
else
  echo "Don't know which GCC package to use - bailing"
  exit 1
fi

GMP_VERSION=6.1.2
MPFR_VERSION=3.1.5
MPC_VERSION=1.0.3

rm -rf extlib
rm -rf hostlib

mkdir -p buildtmp
mkdir -p extlib
mkdir -p hostlib
mkdir -p hostlib/lib
mkdir -p hostlib/include

EXTLIB=$PWD/extlib
HOSTLIB=$PWD/hostlib

pushd .
cd buildtmp

if [ ! -f release-1.8.0.tar.gz ]; then
    wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz
fi

if [ ! -f gmp-${GMP_VERSION}.tar.bz2 ]; then
    wget https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.bz2
fi

if [ ! -f mpfr-${MPFR_VERSION}.tar.gz ]; then
    wget http://www.mpfr.org/mpfr-current/mpfr-${MPFR_VERSION}.tar.gz
fi

if [ ! -f mpc-${MPC_VERSION}.tar.gz ]; then
    wget http://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz
fi

if [ ! -f gcc-arm-none-eabi-${GCC_VERSION}-${GCC_OS}.tar.bz2 ]; then
    wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/6_1-2017q1/gcc-arm-none-eabi-${GCC_VERSION}-${GCC_OS}.tar.bz2
fi

if [ ! -d gcc-arm-none-eabi-${GCC_VERSION} ]; then
    rm -rf gcc-arm-none-eabi-${GCC_VERSION}
    tar xjf gcc-arm-none-eabi-${GCC_VERSION}-${GCC_OS}.tar.bz2
fi

tar xzf release-1.8.0.tar.gz
rm -rf gmp-${GMP_VERSION}
tar xjf gmp-${GMP_VERSION}.tar.bz2
rm -rf mpfr-${MPFR_VERSIO}
tar xzf mpfr-${MPFR_VERSION}.tar.gz
tar xzf mpc-${MPC_VERSION}.tar.gz

pushd .
cd googletest-release-1.8.0/googletest
GTEST_DIR=$PWD
g++ -isystem ${GTEST_DIR}/include -I${GTEST_DIR} \
    -pthread -c ${GTEST_DIR}/src/gtest-all.cc
ar -rv ${HOSTLIB}/lib/libgtest.a gtest-all.o
cp -r ${GTEST_DIR}/include ${HOSTLIB}
popd


OLDPATH=$PATH

export PATH=$PATH:$PWD/gcc-arm-none-eabi-${GCC_VERSION}/bin
export CC=arm-none-eabi-gcc
export CFLAGS="-nostartfiles -ffunction-sections -fdata-sections --specs=nosys.specs -mcpu=cortex-m4 -Os -mfloat-abi=hard -mfpu=fpv4-sp-d16"
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

# Revert path
export PATH=$OLDPATH
unset CC
unset CFLAGS

# Building system packages on hostlib
rm -rf gmp-${GMP_VERSION}
tar xjf gmp-${GMP_VERSION}.tar.bz2
rm -rf mpfr-${MPFR_VERSIO}
tar xzf mpfr-${MPFR_VERSION}.tar.gz
tar xzf mpc-${MPC_VERSION}.tar.gz

pushd .
cd gmp-${GMP_VERSION}
./configure  --disable-assembly --prefix=$HOSTLIB --disable-shared
make -j 4
make install
popd

pushd .
cd mpfr-${MPFR_VERSION}
./configure --disable-assembly --prefix=$HOSTLIB --disable-shared --with-gmp=${HOSTLIB}
make -j 4
make install
popd
popd


touch bootstrap-complete
