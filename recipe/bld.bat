:: Removed @echo off so we can see exactly what Windows is doing

setlocal EnableDelayedExpansion

echo "Building GetFEM with CMake..."
FOR /F "delims=" %%i IN ('python -c "import numpy; print(numpy.get_include())"') DO set "NUMPY_INC=%%i"

:: Build the CMake command safely, appending line-by-line to avoid ALL caret (^) bugs
:: We include %CMAKE_ARGS% here right at the beginning
set "CMAKE_CMD=cmake -B build -G Ninja %CMAKE_ARGS%"
set "CMAKE_CMD=%CMAKE_CMD% -DCMAKE_BUILD_TYPE=Release"
set "CMAKE_CMD=%CMAKE_CMD% -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%""
set "CMAKE_CMD=%CMAKE_CMD% -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%""
set "CMAKE_CMD=%CMAKE_CMD% -DENABLE_PYTHON=ON"
set "CMAKE_CMD=%CMAKE_CMD% -DBUILD_SHARED_LIBS=ON"
set "CMAKE_CMD=%CMAKE_CMD% -DGENERATE_GETFEM_IM_LIST_H=OFF"
set "CMAKE_CMD=%CMAKE_CMD% -DENABLE_FORCE_SINGLETHREAD_BLAS:BOOL=OFF"
set "CMAKE_CMD=%CMAKE_CMD% -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON"
set "CMAKE_CMD=%CMAKE_CMD% -DMUMPS_INC_DIR="%LIBRARY_INC%""
set "CMAKE_CMD=%CMAKE_CMD% -DSMUMPS_LIB="%LIBRARY_LIB%\smumps_seq.lib""
set "CMAKE_CMD=%CMAKE_CMD% -DDMUMPS_LIB="%LIBRARY_LIB%\dmumps_seq.lib""
set "CMAKE_CMD=%CMAKE_CMD% -DCMUMPS_LIB="%LIBRARY_LIB%\cmumps_seq.lib""
set "CMAKE_CMD=%CMAKE_CMD% -DZMUMPS_LIB="%LIBRARY_LIB%\zmumps_seq.lib""
set "CMAKE_CMD=%CMAKE_CMD% -DMUMPS_COMMON_LIB="%LIBRARY_LIB%\mumps_common_seq.lib""
set "CMAKE_CMD=%CMAKE_CMD% -DPORD_LIB="%LIBRARY_LIB%\pord_seq.lib""
set "CMAKE_CMD=%CMAKE_CMD% -DMPISEQ_LIB="%LIBRARY_LIB%\mpiseq_seq.lib""
set "CMAKE_CMD=%CMAKE_CMD% -DPython3_EXECUTABLE="%PYTHON%""
set "CMAKE_CMD=%CMAKE_CMD% -DPython3_NumPy_INCLUDE_DIRS="%NUMPY_INC%""
set "CMAKE_CMD=%CMAKE_CMD% -DBLAS_LIBRARIES="%LIBRARY_LIB%\openblas.lib""
set "CMAKE_CMD=%CMAKE_CMD% -DLAPACK_LIBRARIES="%LIBRARY_LIB%\openblas.lib""

:: Print the exact command to the CI logs for debugging
echo.
echo ==============================================================================
echo EXACT CMAKE COMMAND:
echo %CMAKE_CMD%
echo ==============================================================================
echo.

:: Execute the command
%CMAKE_CMD%
if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1