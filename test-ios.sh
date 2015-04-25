#!/bin/bash


# Tries to links to library here:
# _builds/ios-8-2/Debug-iphoneos/TF.framework/Versions/A/TF
#
# But the lib is really here:
# ios-8-2/Debug-iphoneos/TF.framework/TF

cmake -GXcode -H. -B_builds/web -DCMAKE_TOOLCHAIN_FILE=iOS.cmake && \
xcodebuild -project _builds/web/tf.xcodeproj -target "testa"


find _builds/web -name "TF" -type f
