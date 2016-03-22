LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := example
LOCAL_SRC_FILES := ../../../example/libexample.so
LOCAL_EXPORT_C_INCLUDES := ../../../example
include $(PREBUILT_SHARED_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE := main
LOCAL_CFLAGS := -g -D__ANDROID__ $(LOCAL_CFLAGS)
SDL_PATH := ../SDL2
LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(SDL_PATH)/include $(LOCAL_PATH)/SDL2_image $(LOCAL_PATH)/SDL2_mixer  $(LOCAL_PATH)/SDL2_ttf
LOCAL_SRC_FILES := $(SDL_PATH)/src/main/android/SDL_android_main.c ../../../example/example.c
LOCAL_SHARED_LIBRARIES := SDL2 SDL2_image SDL2_mixer SDL2_ttf example
LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -llog
include $(BUILD_SHARED_LIBRARY)
