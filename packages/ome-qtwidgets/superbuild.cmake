# ome-qtwidgets superbuild

# Options to build from git (defaults to source zip if unset)
set(ome-qtwidgets-head ${head} CACHE BOOL "Force building from current git develop branch")
set(ome-qtwidgets-dir "" CACHE PATH "Local directory containing the OME QtWidgets source code")
set(ome-qtwidgets-git-url "" CACHE STRING "URL of OME QtWidgets git repository")
set(ome-qtwidgets-git-branch "" CACHE STRING "URL of OME QtWidgets git repository")

# Current stable release.
set(RELEASE_URL "https://downloads.openmicroscopy.org/ome-qtwidgets/5.3.1/source/ome-qtwidgets-5.3.1.tar.xz")
set(RELEASE_HASH "SHA512=0c1d4e3d4c1f331caa453a68a2766f48601beac0dd7b8876ed0b2a544a6ab2abf41b739ba55af3e0f5d5c50e0f685fec3e5b84859a7bbf1f889f3fb39f488408")

# Current development branch (defaults for ome-qtwidgets-head option).
set(GIT_URL "https://github.com/ome/ome-qtwidgets.git")
set(GIT_BRANCH "develop")

if(NOT ome-qtwidgets-head)
  if(ome-qtwidgets-git-url)
    set(GIT_URL ${ome-qtwidgets-git-url})
  endif()
  if(ome-qtwidgets-git-branch)
    set(GIT_BRANCH ${ome-qtwidgets-git-branch})
  endif()
endif()

if(ome-qtwidgets-dir)
  set(EP_SOURCE_DOWNLOAD
    DOWNLOAD_COMMAND "")
  set(EP_SOURCE_DIR "${ome-qtwidgets-dir}")
  set(BOOST_VERSION 1.61)
  message(STATUS "Building OME QtWidgets C++ from local directory (${ome-qtwidgets-dir})")
elseif(ome-qtwidgets-head OR ome-qtwidgets-git-url OR ome-qtwidgets-git-branch)
  set(EP_SOURCE_DOWNLOAD
    GIT_REPOSITORY "${GIT_URL}"
    GIT_TAG "${GIT_BRANCH}"
    UPDATE_DISCONNECTED 1)
  set(BOOST_VERSION 1.61)
  message(STATUS "Building OME QtWidgets C++ from git (URL ${GIT_URL}, branch/tag ${GIT_BRANCH})")
else()
  set(EP_SOURCE_DOWNLOAD
    URL "${RELEASE_URL}"
    URL_HASH "${RELEASE_HASH}")
  set(BOOST_VERSION 1.61)
  message(STATUS "Building OME QtWidgets C++ from source release (${RELEASE_URL})")
endif()

# Set dependency list
ome_add_dependencies(ome-qtwidgets
                     DEPENDENCIES ome-files
                     THIRD_PARTY_DEPENDENCIES boost-${BOOST_VERSION} png tiff
                                              glm py-sphinx gtest)

unset(CONFIGURE_OPTIONS)
list(APPEND CONFIGURE_OPTIONS
     "-DBOOST_ROOT=${OME_EP_INSTALL_DIR}"
     -DBoost_NO_BOOST_CMAKE:BOOL=true
     "-DBoost_ADDITIONAL_VERSIONS=${BOOST_VERSION}"
     ${SUPERBUILD_OPTIONS})
if(TARGET gtest)
  list(APPEND CONFIGURE_OPTIONS "-DGTEST_SOURCE=${CMAKE_BINARY_DIR}/gtest-source")
endif()
if(SOURCE_ARCHIVE_DIR)
  list(APPEND CONFIGURE_OPTIONS "-DSOURCE_ARCHIVE_DIR=${SOURCE_ARCHIVE_DIR}")
endif()
string(REPLACE ";" "^^" CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS}")

ExternalProject_Add(${EP_PROJECT}
  ${OME_EP_COMMON_ARGS}
  ${EP_SOURCE_DOWNLOAD}
  SOURCE_DIR ${EP_SOURCE_DIR}
  BINARY_DIR ${EP_BINARY_DIR}
  INSTALL_DIR ""
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBUILD_DIR:PATH=${EP_BINARY_DIR}"
    "-DCONFIGURE_OPTIONS=${CONFIGURE_OPTIONS}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG:FILEPATH=${EP_SCRIPT_CONFIG}"
    -P "${GENERIC_CMAKE_CONFIGURE}"
  BUILD_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBUILD_DIR:PATH=${EP_BINARY_DIR}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG:FILEPATH=${EP_SCRIPT_CONFIG}"
    -P "${GENERIC_CMAKE_BUILD}"
  INSTALL_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBUILD_DIR:PATH=${EP_BINARY_DIR}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG:FILEPATH=${EP_SCRIPT_CONFIG}"
    -P "${GENERIC_CMAKE_INSTALL}"
  TEST_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBUILD_DIR:PATH=${EP_BINARY_DIR}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG:FILEPATH=${EP_SCRIPT_CONFIG}"
    -P "${GENERIC_CMAKE_TEST}"
  DEPENDS
    ${EP_PROJECT}-prerequisites
  )
