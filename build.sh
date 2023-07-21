#!/bin/bash

set -e

export ANDROID_NDK=/Users/wdz/Library/Android/sdk/ndk/21.4.7075529

buildit()
{
    abi=$1
    API=$2

    cmake -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=./$abi \
        -DANDROID_ABI=$abi \
        -DANDROID_NDK=$ANDROID_NDK \
        -DANDROID_PLATFORM=android-$API \
        ..

    make clean    
    make
    make install
}

# if [ -d "./build-android" ]; then
#     rm -r build-android
# fi
# mkdir build-android && cd build-android
# buildit armeabi-v7a 19
# buildit arm64-v8a 21
# cd ..

if [ -d "./build-ios" ]; then
    rm -r build-ios
fi 
mkdir build-ios
cmake -S . \
    -B ./build-ios \
    -DCMAKE_SYSTEM_NAME=iOS \
    "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" \
    -DCMAKE_OSX_SYSROOT="$(xcodebuild -version -sdk iphonesimulator Path)" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=9.0 \
    -DCMAKE_IOS_INSTALL_COMBINED=YES \
    -DCMAKE_CXX_COMPILER_WORKS=YES \
    -DCMAKE_C_COMPILER_WORKS=YES \
    -DCMAKE_INSTALL_PREFIX=./build-ios/install
cmake --build ./build-ios --target install --config Release
