@echo off
setlocal EnableDelayedExpansion

echo "Dynamically finding MUMPS libraries and patching CMakeLists.txt..."
echo import io, os, glob > patch_mumps.py
echo lib_dir = os.environ.get("LIBRARY_LIB", "") >> patch_mumps.py
echo libs = [] >> patch_mumps.py
echo for p in ["*smumps*.lib", "*dmumps*.lib", "*cmumps*.lib", "*zmumps*.lib", "*mumps_common*.lib", "*pord*.lib", "*mpiseq*.lib"]: >> patch_mumps.py
echo     matches = glob.glob(os.path.join(lib_dir, p)) >> patch_mumps.py
echo     if matches: libs.append(matches[0].replace(chr(92), chr(47))) >> patch_mumps.py
echo     print("Pattern", p, "found:", matches) >> patch_mumps.py
echo text = io.open("CMakeLists.txt", encoding="utf-8").read() >> patch_mumps.py
echo text = text.replace("set(MUMPS_LIBS " + chr(34) + chr(34) + ")", "set(MUMPS_LIBS " + chr(34) + ";".join(libs) + chr(34) + ")") >> patch_mumps.py
echo io.open("CMakeLists.txt", "w", encoding="utf-8").write(text) >> patch_mumps.py
python patch_mumps.py

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
  -DPython3_EXECUTABLE="%PYTHON%" ^
  -DPython3_NumPy_INCLUDE_DIRS="%NUMPY_INC%" ^
  -DBLAS_LIBRARIES="%LIBRARY_LIB%\openblas.lib" ^
  -DLAPACK_LIBRARIES="%LIBRARY_LIB%\openblas.lib"

if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1