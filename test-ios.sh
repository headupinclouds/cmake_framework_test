#!/bin/bash

# Tries to links to library here:
# _builds/ios/Debug-iphoneos/TF.framework/Versions/A/TF
#
# But the lib is really here:
# ios/Debug-iphoneos/TF.framework/TF

NAME=_builds/ios
cmake -GXcode -H. -B${NAME} -DCMAKE_TOOLCHAIN_FILE=iOS.cmake && xcodebuild -project ${NAME}/tf.xcodeproj -target "testa"
echo -e "library path:  $(find ${NAME} -name "TF" -type f)"
