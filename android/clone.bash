#!/usr/bin/env bash

# Clone SDL
hg clone http://hg.libsdl.org/SDL jni/SDL2
hg clone http://hg.libsdl.org/SDL_image jni/SDL2_image
hg clone http://hg.libsdl.org/SDL_mixer jni/SDL2_mixer
hg clone http://hg.libsdl.org/SDL_ttf jni/SDL2_ttf

# Disable some modules
sed -i '/^SUPPORT_MOD_MODPLUG ?= true/c\SUPPORT_MOD_MODPLUG ?= false' jni/SDL2_mixer/Android.mk
sed -i '/^SUPPORT_MOD_MIKMOD ?= true/c\SUPPORT_MOD_MIKMOD ?= false' jni/SDL2_mixer/Android.mk
sed -i '/^SUPPORT_MP3_SMPEG ?= true/c\SUPPORT_MP3_SMPEG ?= false' jni/SDL2_mixer/Android.mk
sed -i '/^SUPPORT_TIMIDITY ?= true/c\SUPPORT_TIMIDITY ?= false' jni/SDL2_mixer/Android.mk
sed -i '/^SUPPORT_JPG ?= true/c\SUPPORT_JPG ?= false' jni/SDL2_image/Android.mk
