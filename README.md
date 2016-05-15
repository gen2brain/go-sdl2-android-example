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

Go toolchain must be cross compiled for android. There is a bootstrap script in android dir that you can use to compile toolchains and SDL2 for arm, arm7, arm64, x86 and x86_64.

Make sure you have git, mercurial/hg and curl installed.

Export paths to Android NDK and SDK:

    export ANDROID_NDK=/opt/android-ndk
    export ANDROID_SDK=/opt/android-sdk

If you want to use clang instead of gcc:
    
    export USE_LLVM=1

Bootstrap Go and SDL:

    cd android
    ./bootstrap.bash /usr/local

/usr/local is prefix where Go and Android toolchains will be installed.

After build is complete point GOROOT to new Go installation in /usr/local:

    export GOROOT=/usr/local/go

And export paths to android toolchains, so scripts can find them:

    export ANDROID_TOOLCHAIN_ARM=/usr/local/android-toolchain-arm
    export ANDROID_TOOLCHAIN_ARM7=/usr/local/android-toolchain-arm7
    export ANDROID_TOOLCHAIN_ARM64=/usr/local/android-toolchain-arm64
    export ANDROID_TOOLCHAIN_X86=/usr/local/android-toolchain-x86
    export ANDROID_TOOLCHAIN_X86_64=/usr/local/android-toolchain-x86_64

To build apk with ant:

    cd android
    ./mkapk-ant.bash

To build apk with gradle:

    cd android
    ./mkapk-gradle.bash

If everything is successfully built apk can be found in android/build directory.

You can also import project in Android Studio so you can use CPU monitor, debugger etc. but note that you have to rebuild Go library every time you make changes. You can rebuild like this:

    cd android
    ./mklib.bash arm arm7 arm64 x86 x86_64
