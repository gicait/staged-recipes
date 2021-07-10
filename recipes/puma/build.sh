#!/bin/bash
set -e  # exit when any command fails


# INSTALL pumapy
cd "$SRC_DIR"
$PYTHON setup.py install --single-version-externally-managed --record=record.txt


# INSTALL PuMA C++ library
cd install 

"$SRC_DIR"/cpp/src/createCMakeLists_src.sh
"$SRC_DIR"/cpp/test/createCMakeLists_test.sh

mkdir -p cmake-build-release
cd cmake-build-release
cmake -D CONDA_PREFIX=$BUILD_PREFIX \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      "$SRC_DIR"/cpp
make -j
make install
rm ${PREFIX}/bin/pumaX_examples
rm ${PREFIX}/bin/pumaX_main


# INSTALL TexGen
cd "$SRC_DIR"/install/TexGen
mkdir -p bin
cd bin

PY_VERSION="$(python -c 'import sys; print(sys.version_info[1])')"
if [ $PY_VERSION -le 7 ]; then
    PY_VERSION="${PY_VERSION}m"
fi

# compilation options
cmake -D BUILD_PYTHON_INTERFACE=ON \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D PYTHON_INCLUDE_DIR="$BUILD_PREFIX"/include/python3.$PY_VERSION \
      -D PYTHON_LIBRARY="$BUILD_PREFIX"/lib/libpython3.$PY_VERSION$SHLIB_EXT \
      -D PYTHON_SITEPACKAGES_DIR="$SP_DIR" \
      -D BUILD_GUI=OFF \
      -D BUILD_RENDERER=OFF \
      -D CMAKE_MACOSX_RPATH=ON \
      -D CMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
      -D CMAKE_INSTALL_RPATH="$PREFIX"/lib \
      -D BUILD_SHARED_LIBS=OFF \
      ..

make -j
make install


# INSTALL PuMA GUI
cd "$SRC_DIR"/gui/build
qmake "BUILD_PREFIX=$BUILD_PREFIX" "INSTALL_PREFIX=$PREFIX"
make -j
make install
