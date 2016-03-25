#!/usr/bin/env bash

if [ -z "$ANDROID_NDK" ]; then
  echo "You must define ANDROID_NDK before starting. It must point to your NDK directories."
  exit 1
fi

if [ -z "$ANDROID_SDK" ]; then
  echo "You must define ANDROID_SDK before starting. It must point to your SDK directories."
  exit 1
fi

./make.bash

${ANDROID_SDK}/platform-tools/adb install -r bin/go-sdl2-example-debug.apk

${ANDROID_SDK}/platform-tools/adb shell am start -a android.intent.action.MAIN -n com.example.android/.MainActivity
