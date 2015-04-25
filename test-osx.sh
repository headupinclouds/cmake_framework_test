#!/bin/bash

cmake -GXcode -H. -B_builds/osx  && \
xcodebuild -project _builds/osx/tf.xcodeproj -target "testb"

find _builds/web -name "TF" -type f
