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

Go toolchain must be cross compiled for android/arm. There is a bootstrap script you can use to compile toolchain and SDL2.
Make sure you have mercurial/hg, curl and ant installed.

    ANDROID_NDK=/opt/android-ndk ./bootstrap.bash /usr/local

Point ANDROID_NDK to directory where you unpacked archive, /usr/local is prefix where Go and android toolchains will be installed.

After build is complete you must first compile example to shared library, GOROOT needs to point to toolchain that we compiled for android:

    cd example
    ANDROID_TOOLCHAIN=/usr/local/android-toolchain-arm GOROOT=/usr/local/go ./make.bash

And to build apk:

    cd android
    ANDROID_NDK=/opt/android-ndk ANDROID_NDK=/opt/android-sdk ./make.bash

If everything is successfully built apk can be found in android/bin directory.
