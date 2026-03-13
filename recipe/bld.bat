@echo off
setlocal EnableDelayedExpansion

echo "Building GetFEM with CMake..."

:: Map the developer's CMake command to Conda-Forge environment variables.
:: We drop the Intel-specific MKL flags (-DBLA_VENDOR) since you use libopenblas.
:: We use %LIBRARY_PREFIX% which is Conda's equivalent to C:\opt.

cmake -B build ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DENABLE_PYTHON=ON ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DGENERATE_GETFEM_IM_LIST_H=OFF ^
  -DENABLE_FORCE_SINGLETHREAD_BLAS=OFF ^
  -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -DMUMPS_LIB_DIR="%LIBRARY_LIB%" ^
  -DMUMPS_INC_DIR="%LIBRARY_INC%"

if errorlevel 1 exit 1

:: Build
cmake --build build
if errorlevel 1 exit 1

:: Install
cmake --install build
if errorlevel 1 exit 1