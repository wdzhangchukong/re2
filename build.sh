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

if [ -d "./build-android" ]; then
    rm -r build-android
fi
mkdir build-android && cd build-android
buildit armeabi-v7a 19
buildit arm64-v8a 21
cd ..

buildiOS() {
    sdk=$1
    arch=$2
    cmake -S . \
        -B ./build-ios \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
        -DCMAKE_OSX_ARCHITECTURES=$arch \
        -DCMAKE_OSX_SYSROOT="$(xcodebuild -version -sdk $sdk Path)" \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=9.0 \
        -DCMAKE_IOS_INSTALL_COMBINED=YES \
        -DCMAKE_CXX_COMPILER_WORKS=YES \
        -DCMAKE_C_COMPILER_WORKS=YES \
        -DCMAKE_INSTALL_PREFIX=./build-ios/install-$sdk

    cmake --build ./build-ios --target install --config Release
}

if [ -d "./build-ios" ]; then
    rm -r build-ios
fi
mkdir build-ios
buildiOS iphonesimulator x86_64
buildiOS iphoneos armv7\;arm64
mkdir ./build-ios/install
cp -r ./build-ios/install-iphoneos/lib/re2.framework ./build-ios/install/re2.framework
libtool -static -o ./build-ios/install/re2.framework/re2 ./build-ios/install-iphoneos/lib/re2.framework/re2 ./build-ios/install-iphonesimulator/lib/re2.framework/re2
