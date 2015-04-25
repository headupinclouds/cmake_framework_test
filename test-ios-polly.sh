#!/bin/bash

# Tries to links to library here:
# _builds/ios-8-2/Debug-iphoneos/TF.framework/Versions/A/TF
#
# But the lib is really here:
# ios-8-2/Debug-iphoneos/TF.framework/TF

build.py --toolchain ios-8-2 --verbose --jobs 8 --clear
