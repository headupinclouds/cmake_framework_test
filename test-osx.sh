#!/bin/bash

# _builds/osx/Debug-iphoneos/TF.framework/Versions/A/TF

NAME=_builds/osx
cmake -GXcode -H. -B${NAME} && xcodebuild -project ${NAME}/tf.xcodeproj -target "testb"
echo -e "library path: $(find ${NAME} -name "TF" -type f)"
