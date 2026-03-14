#!/usr/bin/env bash
set -ex

echo "**************** G E T F E M  B U I L D  S T A R T S  H E R E ****************"

export CFLAGS="$CFLAGS -Wno-error=incompatible-pointer-types"
export CXXFLAGS="$CXXFLAGS -Wno-error=incompatible-pointer-types"

NUMPY_INC=$($PYTHON -c "import numpy; print(numpy.get_include())")

cmake -B build \
    -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DENABLE_PYTHON=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DGENERATE_GETFEM_IM_LIST_H=OFF \
    -DMUMPS_INC_DIR="$PREFIX/include" \
    -DMUMPS_LIB_DIR="$PREFIX/lib" \
    -DPython3_EXECUTABLE="$PYTHON" \
    -DPython3_NumPy_INCLUDE_DIRS="$NUMPY_INC"

cmake --build build
cmake --install build

echo "**************** G E T F E M  B U I L D  E N D S  H E R E ****************"