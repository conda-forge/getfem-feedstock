@echo off
setlocal EnableDelayedExpansion

echo "Building GetFEM with CMake..."
FOR /F "delims=" %%i IN ('python -c "import numpy; print(numpy.get_include())"') DO set "NUMPY_INC=%%i"

cmake -B build ^
  -G Ninja ^
  %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DENABLE_PYTHON=ON ^
  -DBUILD_SHARED_LIBS=ON ^
  -DGENERATE_GETFEM_IM_LIST_H=OFF ^
  -DENABLE_MULTITHREADED_BLAS=ON ^
  -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -DMUMPS_INC_DIR="%LIBRARY_INC%" ^
  -DMUMPS_LIB_DIR="%LIBRARY_LIB%" ^
  -DPython3_EXECUTABLE="%PYTHON%" ^
  -DPython3_NumPy_INCLUDE_DIRS="%NUMPY_INC%" ^
  -DBLAS_LIBRARIES="%LIBRARY_LIB%\openblas.lib" ^
  -DLAPACK_LIBRARIES="%LIBRARY_LIB%\openblas.lib"

if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1