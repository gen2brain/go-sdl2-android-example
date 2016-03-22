#!/usr/bin/env bash

./make.bash

adb install -r bin/go-sdl2-example-debug.apk

adb shell am start -a android.intent.action.MAIN -n com.example.android/.MainActivity
