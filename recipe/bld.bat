@echo off
setlocal EnableDelayedExpansion

echo "Dynamically finding MUMPS and OpenBLAS libraries..."
echo import io, os, glob > patch_mumps.py
echo lib_dir = os.environ.get("LIBRARY_LIB", "") >> patch_mumps.py
echo libs = [] >> patch_mumps.py
echo for p in ["*smumps*.lib", "*dmumps*.lib", "*cmumps*.lib", "*zmumps*.lib", "*mumps_common*.lib", "*pord*.lib", "*mpiseq*.lib"]: >> patch_mumps.py
echo     matches = glob.glob(os.path.join(lib_dir, p)) >> patch_mumps.py
echo     if matches: libs.append(matches[0].replace(chr(92), chr(47))) >> patch_mumps.py
echo text = io.open("CMakeLists.txt", encoding="utf-8").read() >> patch_mumps.py
echo text = text.replace("set(MUMPS_LIBS " + chr(34) + chr(34) + ")", "set(MUMPS_LIBS " + chr(34) + ";".join(libs) + chr(34) + ")") >> patch_mumps.py
echo io.open("CMakeLists.txt", "w", encoding="utf-8").write(text) >> patch_mumps.py
echo ob_matches = glob.glob(os.path.join(lib_dir, "*openblas*.lib")) >> patch_mumps.py
echo if ob_matches: print(ob_matches[0].replace(chr(92), chr(47))) >> patch_mumps.py
python patch_mumps.py

FOR /F "delims=" %%i IN ('python -c "import numpy; print(numpy.get_include())"') DO set "NUMPY_INC=%%i"
FOR /F "delims=" %%i IN ('python patch_mumps.py') DO set "OPENBLAS_LIB=%%i"

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
  -DBLAS_LIBRARIES="%OPENBLAS_LIB%" ^
  -DLAPACK_LIBRARIES="%OPENBLAS_LIB%"

if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1