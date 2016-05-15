#!/usr/bin/env bash

if [ -z "$ANDROID_NDK" ]; then
  echo "You must define ANDROID_NDK before starting. It should point to your NDK directories."
  exit 1
fi

if [ -z "$ANDROID_SDK" ]; then
  echo "You must define ANDROID_SDK before starting. It should point to your SDK directories."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: mkapk-ant.bash [release|debug]"
  exit 1
fi

echo "sdk.dir=${ANDROID_SDK}" > local.properties
echo "ndk.dir=${ANDROID_NDK}" >> local.properties

if [ -n "$USE_LLVM" ]; then
    grep -q "NDK_TOOLCHAIN_VERSION" jni/Application.mk || echo "NDK_TOOLCHAIN_VERSION := clang" >> jni/Application.mk
fi

if [ ! -d "jni/SDL2" ]; then
    ./clone.bash
fi

./mklib.bash arm arm64 x86 x86_64 || exit 1

if [ $1 == "release" ]; then
    ${ANDROID_NDK}/ndk-build V=1 -j$(nproc) && ant clean release
elif [ $1 == "debug" ]; then
    ${ANDROID_NDK}/ndk-build V=1 -j$(nproc) && ant clean debug
fi
