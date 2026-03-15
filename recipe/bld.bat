@echo off
setlocal EnableDelayedExpansion

echo "Dynamically finding MUMPS libraries and patching CMakeLists.txt..."
echo import io, os, glob > patch_cmake.py
echo lib_dir = os.environ.get("LIBRARY_LIB", "").replace(chr(92), chr(47)) >> patch_cmake.py
echo ob_path = os.path.join(lib_dir, "openblas.lib").replace(chr(92), chr(47)) >> patch_cmake.py
echo libs = [] >> patch_cmake.py
echo for p in ["*smumps*.lib", "*dmumps*.lib", "*cmumps*.lib", "*zmumps*.lib", "*mumps_common*.lib", "*pord*.lib", "*mpiseq*.lib"]: >> patch_cmake.py
echo     matches = glob.glob(os.path.join(lib_dir, p)) >> patch_cmake.py
echo     if matches: libs.append(matches[0].replace(chr(92), chr(47))) >> patch_cmake.py
echo text = io.open("CMakeLists.txt", encoding="utf-8").read() >> patch_cmake.py
echo text = text.replace("set(MUMPS_LIBS " + chr(34) + chr(34) + ")", "set(MUMPS_LIBS " + chr(34) + ";".join(libs) + chr(34) + ")") >> patch_cmake.py
:: Fixes the syntax warnings by keeping these strictly on one line
echo text = text.replace("find_package(BLAS REQUIRED)", "set(BLAS_FOUND TRUE)\nset(BLAS_LIBRARIES " + chr(34) + ob_path + chr(34) + ")") >> patch_cmake.py
echo text = text.replace("find_package(LAPACK REQUIRED)", "set(LAPACK_FOUND TRUE)\nset(LAPACK_LIBRARIES " + chr(34) + ob_path + chr(34) + ")") >> patch_cmake.py
echo io.open("CMakeLists.txt", "w", encoding="utf-8").write(text) >> patch_cmake.py

python patch_cmake.py
if errorlevel 1 exit 1

FOR /F "delims=" %%i IN ('python -c "import numpy; print(numpy.get_include())"') DO set "NUMPY_INC=%%i"
set "NUMPY_INC=%NUMPY_INC:\=/%"

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
  -DPython3_NumPy_INCLUDE_DIRS="%NUMPY_INC%"

if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1