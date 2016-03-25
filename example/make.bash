#!/usr/bin/env bash

if [ -z "$ANDROID_TOOLCHAIN" ]; then
  echo "You must define ANDROID_TOOLCHAIN before starting. It must point to directory where you have installed arm toolchain."
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH=$ANDROID_TOOLCHAIN/bin:${PATH}
export CC=arm-linux-androideabi-gcc
export CXX=arm-linux-androideabi-g++
export PKG_CONFIG_PATH=$ANDROID_TOOLCHAIN/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$ANDROID_TOOLCHAIN/lib/pkgconfig

GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 ${GOROOT}/bin/go build -v -x -buildmode=c-shared -o=${DIR}/libexample.so ${DIR}/example.go
