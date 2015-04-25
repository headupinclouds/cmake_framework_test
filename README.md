# cmake_framework_test

This is intended as a simple unit test to illustrate an apparent link and build location mismatch when linking a 
framework to an iOS application using the "standard" [ios toolchain](https://code.google.com/p/ios-cmake/).
I've included the ios toolchain in this repository to make it easy to reproduce the issue. 
I've include both the iOS application that reproduces the link error, and an OS X application, which links
to the library in correct framework location.  I'm looking for a CMakeLists.txt fix or possible workaround.
There are two top level convenience bash scripts for building the applications with cmake using an xcode generator.
```
cmake --version
cmake version 3.2.1
```

### iOS framework and application error:

```
bash -fx ./test-ios.sh 
+ NAME=_builds/ios
+ cmake -GXcode -H. -B_builds/ios -DCMAKE_TOOLCHAIN_FILE=iOS.cmake

<snip>
clang: error: no such file or directory: '/Users/dhirvonen/devel/cmake_framework_test/_builds/ios/Debug-iphoneos/TF.framework/Versions/A/TF'
** BUILD FAILED **
The following build commands failed:
	Ld _builds/ios/Debug-iphoneos/testa.app/testa normal armv7
(1 failure)
library path:  _builds/ios/Debug-iphoneos/TF.framework/TF
```
This produces a flat framework layout (ignoring the FRAMEWORK_VERSION property (which is fine with me))
```
tree _builds/osx/Debug/TF.framework/
_builds/osx/Debug/TF.framework/
├── Resources -> Versions/Current/Resources
├── TF -> Versions/Current/TF
└── Versions
    ├── A
    │   ├── Resources
    │   │   └── Info.plist
    │   ├── TF
    │   └── _CodeSignature
    │       └── CodeResources
    └── Current -> A
```

But when I call

```
target_link_libraries(testa TF)
```

for the ios application, the link command fails, since it seems to expect the library to be in a versioned 
framework layout:

```
TF.framework/Versions/A/TF
```

instead it looks like this

```
TF.framework/TF
```

I'm looking for a solution to either:
* correct the TF link path to use the actual (non versioned) framework layout that is currently generated, or
* correct the framework so that it uses the versioned layout to make that consistent with the link path 

### OS X framework and application success:

When I build this for OS X it seems to work fine.

```
bash -fx ./test-osx.sh
+ NAME=_builds/osx
+ cmake -GXcode -H. -B_builds/osx
<snip>
** BUILD SUCCEEDED **
library path: _builds/osx/Debug/TF.framework/Versions/A/TF
```

This produces a framework with the following layout:
```
tree _builds/osx/Debug/
_builds/osx/Debug/
├── TF.framework
│   ├── Resources -> Versions/Current/Resources
│   ├── TF -> Versions/Current/TF
│   └── Versions
│       ├── A
│       │   ├── Resources
│       │   │   └── Info.plist
│       │   ├── TF
│       │   └── _CodeSignature
│       │       └── CodeResources
│       └── Current -> A
└── testb
```

and the call to
```
target_link_libraries(testb TF)
```
Picks up the TF library in the correct location.
