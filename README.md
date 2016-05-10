Go-SDL2 Android Example
=======================

[Go-SDL2](https://github.com/veandco/go-sdl2) example running on Android.

Golang example is compiled to C shared library and then linked with the help of Android.mk files from SDL2.

SDLActivity.java is used, same as with C/C++ and SDL2.

Download APK
------------

[go-sdl2-example-debug.apk](https://github.com/gen2brain/go-sdl2-android-example/releases/download/1.0/go-sdl2-example-debug.apk)

Compile
-------

To compile example you will need [Android NDK](https://developer.android.com/ndk/downloads/index.html) and [Android SDK](http://developer.android.com/sdk/index.html#Other) , download and unpack archives somewhere.

Go toolchain must be cross compiled for android. There is a bootstrap script in android dir that you can use to compile toolchains and SDL2 for arm, arm64, x86 and x86_64.

Make sure you have mercurial/hg, curl and ant installed.

    export ANDROID_NDK=/opt/android-ndk
    export ANDROID_SDK=/opt/android-sdk

    cd android
    ./bootstrap.bash /usr/local

/usr/local is prefix where Go and Android toolchains will be installed.

After build is complete point GOROOT to new Go installation in /usr/local:

    export GOROOT=/usr/local/go

And export directories to android toolchains, so scripts can find them:

    export ANDROID_TOOLCHAIN_ARM=/usr/local/android-toolchain-arm
    export ANDROID_TOOLCHAIN_ARM64=/usr/local/android-toolchain-arm64
    export ANDROID_TOOLCHAIN_X86=/usr/local/android-toolchain-x86
    export ANDROID_TOOLCHAIN_X86_64=/usr/local/android-toolchain-x86_64

To build apk:

    cd android
    ./mkapk.bash

If everything is successfully built apk can be found in android/bin directory.
