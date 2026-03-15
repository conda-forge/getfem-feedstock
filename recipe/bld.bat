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

echo import os, io, glob > patch_cmake.py
echo lib_dir = os.environ.get("LIBRARY_LIB", "").replace(chr(92), chr(47)) >> patch_cmake.py
echo ob_path = os.path.join(lib_dir, "openblas.lib").replace(chr(92), chr(47)) >> patch_cmake.py
echo libs = [] >> patch_cmake.py
echo for p in ["*smumps*.lib", "*dmumps*.lib", "*cmumps*.lib", "*zmumps*.lib", "*mumps_common*.lib", "*pord*.lib", "*mpiseq*.lib"]: >> patch_cmake.py
echo     matches = glob.glob(os.path.join(lib_dir, p)) >> patch_cmake.py
echo     if matches: libs.append(matches[0].replace(chr(92), chr(47))) >> patch_cmake.py
echo mumps_libs_str = ";".join(libs) >> patch_cmake.py
echo with io.open("CMakeLists.txt", "r", encoding="utf-8") as f: >> patch_cmake.py
echo     text = f.read() >> patch_cmake.py
:: Safely replace using chr(34) for double quotes to avoid cmd.exe parsing errors
echo text = text.replace("set(MUMPS_LIBS " + chr(34) + chr(34) + ")", "set(MUMPS_LIBS " + chr(34) + mumps_libs_str + chr(34) + ")") >> patch_cmake.py
echo blas_fix = "set(BLAS_FOUND TRUE)\nset(BLAS_LIBRARIES " + chr(34) + ob_path + chr(34) + ")" >> patch_cmake.py
echo lapack_fix = "set(LAPACK_FOUND TRUE)\nset(LAPACK_LIBRARIES " + chr(34) + ob_path + chr(34) + ")" >> patch_cmake.py
echo text = text.replace("find_package(BLAS REQUIRED)", blas_fix) >> patch_cmake.py
echo text = text.replace("find_package(LAPACK REQUIRED)", lapack_fix) >> patch_cmake.py
echo with io.open("CMakeLists.txt", "w", encoding="utf-8") as f: >> patch_cmake.py
echo     f.write(text) >> patch_cmake.py

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
  -DPython3_SITELIB="%SP_DIR_FWD%" ^
  -DPython3_SITEARCH="%SP_DIR_FWD%"

if errorlevel 1 exit 1

cmake --build build --config Release
if errorlevel 1 exit 1

cmake --install build --config Release
if errorlevel 1 exit 1

:: Move the Python package from the Library prefix to the actual Conda site-packages directory
echo "Moving Python package to %SP_DIR%..."
if not exist "%SP_DIR%" mkdir "%SP_DIR%"
move /Y "%LIBRARY_PREFIX%\Lib\site-packages\getfem" "%SP_DIR%\"
if errorlevel 1 exit 1