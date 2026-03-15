@echo off
setlocal EnableDelayedExpansion

:: Silence MSVC's strict CRT deprecation warnings, required by GetFEM
set "CFLAGS=%CFLAGS% -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE"
set "CXXFLAGS=%CXXFLAGS% -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE"

:: Fix MSVC missing 'not', 'and', 'or' keywords via forced include
set "CXXFLAGS=%CXXFLAGS% -FIiso646.h"

:: Silence massive C4190 warnings regarding std::complex C-linkage
set "CXXFLAGS=%CXXFLAGS% -wd4190"

echo "Dynamically finding MUMPS libraries and patching CMakeLists.txt..."
(
echo import os, io, glob
echo lib_dir = os.environ.get("LIBRARY_LIB", "").replace("\\", "/")
echo ob_path = os.path.join(lib_dir, "openblas.lib").replace("\\", "/")
echo libs = []
echo for p in ["*smumps*.lib", "*dmumps*.lib", "*cmumps*.lib", "*zmumps*.lib", "*mumps_common*.lib", "*pord*.lib", "*mpiseq*.lib"]:
echo     matches = glob.glob(os.path.join(lib_dir, p))
echo     if matches: libs.append(matches[0].replace("\\", "/"))
echo mumps_libs_str = ";".join(libs)
echo with io.open("CMakeLists.txt", "r", encoding="utf-8") as f:
echo     text = f.read()
echo # Fix MUMPS discovery
echo text = text.replace('set(MUMPS_LIBS "")', f'set(MUMPS_LIBS "{mumps_libs_str}")')
echo # Fix BLAS/LAPACK to use OpenBLAS directly and avoid find_package calls
echo blas_fix = f'set(BLAS_FOUND TRUE)\nset(BLAS_LIBRARIES "{ob_path}")'
echo lapack_fix = f'set(LAPACK_FOUND TRUE)\nset(LAPACK_LIBRARIES "{ob_path}")'
echo text = text.replace("find_package(BLAS REQUIRED)", blas_fix)
echo text = text.replace("find_package(LAPACK REQUIRED)", lapack_fix)
echo with io.open("CMakeLists.txt", "w", encoding="utf-8") as f:
echo     f.write(text)
) > patch_cmake.py

python patch_cmake.py
if errorlevel 1 exit 1

:: Get Numpy Include path and format it
FOR /F "delims=" %%i IN ('python -c "import numpy; print(numpy.get_include())"') DO set "NUMPY_INC=%%i"
set "NUMPY_INC=%NUMPY_INC:\=/%"

:: Get Conda's Site-Packages directory and format it
set "SP_DIR_FWD=%SP_DIR:\=/%"

echo "Building GetFEM with CMake..."

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
  -DPython3_EXECUTABLE="%PYTHON%" ^
  -DPython3_NumPy_INCLUDE_DIRS="%NUMPY_INC%" ^
  -DPYTHON_SITE_PACKAGES="%SP_DIR_FWD%"

if errorlevel 1 exit 1

cmake --build build --config Release
if errorlevel 1 exit 1

cmake --install build --config Release
if errorlevel 1 exit 1