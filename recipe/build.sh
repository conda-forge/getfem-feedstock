#!/usr/bin/env bash
set -ex

echo "**************** G E T F E M  B U I L D  S T A R T S  H E R E ****************"

export CFLAGS="$CFLAGS -Wno-error=incompatible-pointer-types"
export CXXFLAGS="$CXXFLAGS -Wno-error=incompatible-pointer-types"

# Fix upstream CMakeLists.txt syntax error (missing quote AND keeping the closing parenthesis)
python -c "import io; text = io.open('CMakeLists.txt', encoding='utf-8').read(); text = text.replace('\"Set C++ standard version (default: 14))', '\"Set C++ standard version (default: 14)\")'); io.open('CMakeLists.txt', 'w', encoding='utf-8').write(text)"

if [[ "$target_platform" == osx-* ]]; then
  EXT=".dylib"
else
  EXT=".so"
fi

NUMPY_INC=$($PYTHON -c "import numpy; print(numpy.get_include())")

cmake -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DENABLE_PYTHON=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DGENERATE_GETFEM_IM_LIST_H=OFF \
    -DMUMPS_INC_DIR="$PREFIX/include" \
    -DSMUMPS_LIB="$PREFIX/lib/libsmumps_seq${EXT}" \
    -DDMUMPS_LIB="$PREFIX/lib/libdmumps_seq${EXT}" \
    -DCMUMPS_LIB="$PREFIX/lib/libcmumps_seq${EXT}" \
    -DZMUMPS_LIB="$PREFIX/lib/libzmumps_seq${EXT}" \
    -DMUMPS_COMMON_LIB="$PREFIX/lib/libmumps_common_seq${EXT}" \
    -DPORD_LIB="$PREFIX/lib/libpord_seq${EXT}" \
    -DMPISEQ_LIB="$PREFIX/lib/libmpiseq_seq${EXT}" \
    -DPython3_EXECUTABLE="$PYTHON" \
    -DPython3_NumPy_INCLUDE_DIRS="$NUMPY_INC"

cmake --build build
cmake --install build

echo "**************** G E T F E M  B U I L D  E N D S  H E R E ****************"