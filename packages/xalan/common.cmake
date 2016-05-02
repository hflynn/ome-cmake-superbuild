if(WIN32)
  set(XALAN_CONFIG "Debug")
  if(CONFIG MATCHES "Rel")
    set(XALAN_CONFIG "Release")
  endif()

  set(XALAN_PLATFORM Win32)
  if(EP_PLATFORM_BITS STREQUAL 64)
    set(XALAN_PLATFORM x64)
  endif()

  set(XALAN_PLATFORM_PATH Win32)
  if(EP_PLATFORM_BITS STREQUAL 64)
    set(XALAN_PLATFORM_PATH Win64)
  endif()

  # VS 12.0
  if(NOT MSVC_VERSION VERSION_LESS 1800 AND MSVC_VERSION VERSION_LESS 1900)
    set(XALAN_SOLUTION VC12)
  # VS 14.0
  elseif(NOT MSVC_VERSION VERSION_LESS 1900 AND MSVC_VERSION VERSION_LESS 2000)
    set(XALAN_SOLUTION VC14)
  else()
    message(FATAL_ERROR "VS version not supported by xalan")
  endif()

  set(XALAN_BINARY_DIR "${SOURCE_DIR}/c/Build/${XALAN_PLATFORM_PATH}/${XALAN_SOLUTION}/${XALAN_CONFIG}")
else()
  # XERCESCROOT is required since the Xalan build uses it to overwrite DYLD_LIBRARY_PATH,
  # which breaks the build (we already set it ourselves).
  set(ENV{XERCESCROOT} "${OME_EP_INSTALL_DIR}")
  set(ENV{XALANCROOT} "${BUILD_DIR}")
  set(ENV{XALAN_LOCALE_SYSTEM} "inmem")
  set(ENV{XALAN_LOCALE} "en_US")
endif()
