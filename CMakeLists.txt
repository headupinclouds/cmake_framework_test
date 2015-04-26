cmake_minimum_required(VERSION 3.0)

project(tf)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

option(ENABLE_TF_SHARED "Build shared libraries"  ON)
if(ENABLE_TF_SHARED)
  message("BUILD_SHARED_LIBS ON")
  set(BUILD_SHARED_LIBS ON)
else()
  message("BUILD_SHARED_LIBS OFF")
  set(BUILD_SHARED_LIBS OFF)
endif()

## the following are directories where stuff will be installed to
## (see taglib/CMakeLists.txt)
set(LIB_SUFFIX_TXT "Define suffix of directory name (32/64)")
set(EXEC_INSTALL_PREFIX_TXT "Base directory for executables and libraries")
set(BIN_INSTALL_DIR_TXT "The subdirectory to the binaries prefix (default prefix/bin)")
set(LIB_INSTALL_TXT "The subdirectory relative to the install prefix where libraries will be installed (default is /lib${LIB_SUFFIX}")
set(INCLUDE_INSTALL_DIR_TXT "The subdirectory to the header prefix")

set(LIB_SUFFIX "" CACHE STRING "${LIB_SUFFIX_TXT}")
set(EXEC_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH "${EXEC_INSTALL_PREFIX_TXT}" FORCE)
set(BIN_INSTALL_DIR "${EXEC_INSTALL_PREFIX}/bin" CACHE PATH "${BIN_INSTALL_DIR_TXT}" FORCE)
set(LIB_INSTALL_DIR "${EXEC_INSTALL_PREFIX}/lib${LIB_SUFFIX}" CACHE PATH "${LIB_INSTALL_TXT}" FORCE)
set(INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "${INCLUDE_INSTALL_DIR_TXT}" FORCE)

include(AlwaysFullRPATH)

# see: http://www.cmake.org/Wiki/CMake_RPATH_handling ("Always full RPATH")
always_full_rpath()

# http://www.kitware.com/blog/home/post/510
if(APPLE)
  option(BUILD_FRAMEWORK "Build an OS X framework" ON)
  set(CMAKE_MACOSX_RPATH 1)
  set(FRAMEWORK_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE STRING "Directory to install frameworks to.")
  set(LIB_INSTALL_DIR ${FRAMEWORK_INSTALL_DIR}) # IMPORTANT, update lib dir for framework builds
endif()

# Testing versioned libs and Framework builds (based on https://github.com/taglib/taglib)

# Library configuration stuff 
set(TF_FRAMEWORK_VERSION "A")
set(TF_LIB_MAJOR_VERSION "1")
set(TF_LIB_MINOR_VERSION "0")
set(TF_LIB_PATCH_VERSION "0")
set(TF_LIB_VERSION_STRING "${TF_LIB_MAJOR_VERSION}.${TF_LIB_MINOR_VERSION}.${TF_LIB_PATCH_VERSION}")

# 1. If the library source code has changed at all since the last update, then increment revision.
# 2. If any interfaces have been added, removed, or changed since the last update, increment current, and set revision to 0.
# 3. If any interfaces have been added since the last public release, then increment age.
# 4. If any interfaces have been removed since the last public release, then set age to 0. 
set(TF_SOVERSION_CURRENT  1)
set(TF_SOVERSION_REVISION 0)
set(TF_SOVERSION_AGE      0)

math(EXPR TF_SOVERSION_MAJOR "${TF_SOVERSION_CURRENT} - ${TF_SOVERSION_AGE}")
math(EXPR TF_SOVERSION_MINOR "${TF_SOVERSION_AGE}")
math(EXPR TF_SOVERSION_PATCH "${TF_SOVERSION_REVISION}")

##################################
##### Build lib and framework ####
##################################

set(TF_SOVERSION ${TF_SOVERSION_MAJOR}.${TF_SOVERSION_MINOR}.${TF_SOVERSION_PATCH})
set(TF_SRCS exa.cpp)
set(TF_PUBLIC_HDRS exa.hpp)
add_library(TF SHARED ${TF_SRCS})

#target_link_libraries(TF ${SOME_LIBS})

# See CMake Framework test
# https://github.com/Kitware/CMake/blob/master/Tests/Framework/CMakeLists.txt

message("LIB_INSTALL_DIR: ${LIB_INSTALL_DIR}")

set_target_properties(TF PROPERTIES
  FRAMEWORK TRUE
  VERSION ${TF_SOVERSION}
  SOVERSION ${TF_SOVERSION_MAJOR}
  FRAMEWORK_VERSION ${TF_FRAMEWORK_VERSION}
  INSTALL_RPATH ${LIB_INSTALL_DIR}
  INSTALL_NAME_DIR @rpath
  PUBLIC_HEADER "${TF_PUBLIC_HDRS}" 
  PRIVATE_HEADER ""
  RESOURCE ""
  LINK_INTERFACE_LIBRARIES ""
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer" # Needed by web-ios
  )

install(TARGETS TF
  FRAMEWORK DESTINATION ${FRAMEWORK_INSTALL_DIR}
  LIBRARY DESTINATION ${LIB_INSTALL_DIR}
  ARCHIVE DESTINATION ${LIB_INSTALL_DIR}
  RUNTIME DESTINATION ${BIN_INSTALL_DIR}

  # These are ignored on the Mac... and things are automatically placed in
  # their appropriate Framework sub-folder at build time. (And then the built
  # framework is copied recursively when it is installed.)
  # But they are required to be present so that installing a framework on other
  # other platforms will install the pieces of the framework without having to
  # duplicate install rules for the pieces of the framework.
  PUBLIC_HEADER DESTINATION ${INCLUDE_INSTALL_DIR}/TF
  PRIVATE_HEADER DESTINATION ${CMAKE_INSTALL_PREFIX}/share/TF/PrivateHeaders
  RESOURCE DESTINATION ${CMAKE_INSTALL_PREFIX}/share/TF/Resources
)

get_cmake_property(_variableNames VARIABLES)
foreach (_variableName ${_variableNames})
    message(STATUS "VARIABLE: ${_variableName}=${${_variableName}}")
endforeach()

if(IOS) # use this test for toolchain compatibility

  #################################################
  ##### Build an ios app and link to framework ####
  #################################################

  add_executable(testa testa.mm)

  # http://ebitg.wordpress.com/2012/04/24/cmake-iphone-support/
  set(PRODUCT_NAME testa)
  set(EXECUTABLE_NAME testa)
  set(APP_IDENTIFIER com.example.testa)
  CONFIGURE_FILE("${CMAKE_CURRENT_LIST_DIR}/Info.plist.in" "${CMAKE_CURRENT_LIST_DIR}/Info.plist")

  set_target_properties(testa PROPERTIES
    MACOSX_BUNDLE YES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_LIST_DIR}/Info.plist"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
    )

  #set_target_properties(testa PROPERTIES SHARED_LIBRARY_FLAGS $<TARGET_FILE:TF>)

  target_link_libraries(testa TF)
  # get_target_property(tf_location TF LOCATION)
  # message("${tf_location}")
  # message("LIBRARY AT: $<TARGET_FILE:TF>")

elseif(APPLE) # should be 
  
  add_executable(testb testb.cpp)
  target_link_libraries(testb TF)

endif()

