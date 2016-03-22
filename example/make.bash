#!/usr/bin/env bash

ANDROID_TOOLCHAIN="/opt/android-toolchain-arm"

export PATH=/opt/android-toolchain-arm/bin:${PATH}
export CC=arm-linux-androideabi-gcc
export CXX=arm-linux-androideabi-g++
export PKG_CONFIG_PATH=$ANDROID_TOOLCHAIN/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$ANDROID_TOOLCHAIN/lib/pkgconfig

GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 go build -v -x -work -buildmode=c-shared -o=libexample.so example.go
