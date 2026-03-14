#!/usr/bin/env bash
set -ex

echo "**************** G E T F E M  B U I L D  S T A R T S  H E R E ****************"

# Downgrade the strict GCC 14 pointer error to a warning just in case
export CFLAGS="$CFLAGS -Wno-error=incompatible-pointer-types"
export CXXFLAGS="$CXXFLAGS -Wno-error=incompatible-pointer-types"

# Future-proofing for macOS: Set the correct shared library extension
if [[ "$target_platform" == osx-* ]]; then
  EXT=".dylib"
else
  EXT=".so"
fi

# Configure with CMake
# Explicitly map the MUMPS sequential libraries to bypass the missing _seq suffixes
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
    -DMPISEQ_LIB="$PREFIX/lib/libmpiseq_seq${EXT}"

# Build and install
cmake --build build
cmake --install build

echo "**************** G E T F E M  B U I L D  E N D S  H E R E ****************"