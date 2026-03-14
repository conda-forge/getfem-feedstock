@echo off
setlocal EnableDelayedExpansion

echo "Building GetFEM with CMake..."
FOR /F "delims=" %%i IN ('python -c "import numpy; print(numpy.get_include())"') DO set "NUMPY_INC=%%i"

cmake -B build ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE="Release" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DENABLE_PYTHON="ON" ^
  -DBUILD_SHARED_LIBS="ON" ^
  -DGENERATE_GETFEM_IM_LIST_H="OFF" ^
  -DENABLE_FORCE_SINGLETHREAD_BLAS="OFF" ^
  -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS="ON" ^
  -DMUMPS_INC_DIR="%LIBRARY_INC%" ^
  -DSMUMPS_LIB="%LIBRARY_LIB%\smumps_seq.lib" ^
  -DDMUMPS_LIB="%LIBRARY_LIB%\dmumps_seq.lib" ^
  -DCMUMPS_LIB="%LIBRARY_LIB%\cmumps_seq.lib" ^
  -DZMUMPS_LIB="%LIBRARY_LIB%\zmumps_seq.lib" ^
  -DMUMPS_COMMON_LIB="%LIBRARY_LIB%\mumps_common_seq.lib" ^
  -DPORD_LIB="%LIBRARY_LIB%\pord_seq.lib" ^
  -DMPISEQ_LIB="%LIBRARY_LIB%\mpiseq_seq.lib" ^
  -DPython3_EXECUTABLE="%PYTHON%" ^
  -DPython3_NumPy_INCLUDE_DIRS="%NUMPY_INC%" ^
  -DBLAS_LIBRARIES="%LIBRARY_LIB%\openblas.lib" ^
  -DLAPACK_LIBRARIES="%LIBRARY_LIB%\openblas.lib"

if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1