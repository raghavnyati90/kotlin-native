@echo off
rem based on scalac.bat from the Scala distribution
rem ##########################################################################
rem # Copyright 2002-2011, LAMP/EPFL
rem # Copyright 2011-2017, JetBrains
rem #
rem # This is free software; see the distribution for copying conditions.
rem # There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
rem # PARTICULAR PURPOSE.
rem ##########################################################################

setlocal enabledelayedexpansion
call :set_home
call :set_path

set "TOOL_NAME=%1"
shift

if "%_TOOL_CLASS%"=="" set _TOOL_CLASS=org.jetbrains.kotlin.cli.utilities.MainKt

if not "%JAVA_HOME%"=="" (
  if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
)

if "%_JAVACMD%"=="" set _JAVACMD=java

set JAVA_ARGS=
set KONAN_ARGS=

:again
set "ARG=%1"
if not "!ARG!" == "" (
    if "!ARG:~0,2!" == "-D" (
        set "JAVA_ARGS=%JAVA_ARGS% %ARG%"
        goto next
    )
    if "!ARG:~0,2!" == "-J" (
        set "JAVA_ARGS=%JAVA_ARGS% !ARG:~2!"
        goto next
    )
    if "!ARG:~0,2!" == "-X" (
        echo "TODO: need to pass arguments to all the tools somehow."
        goto next
    )
    if "!ARG!" == "--time" (
        set "KONAN_ARGS=%KONAN_ARGS% --time"
        set "JAVA_ARGS=%JAVA_ARGS% -agentlib:hprof=cpu=samples -Dkonan.profile=true"
        goto next
    )

    set "KONAN_ARGS=%KONAN_ARGS% %ARG%"

    :next
    shift
    goto again
)

set "NATIVE_LIB=%_KONAN_HOME%\konan\nativelib"
set "KONAN_LIB=%_KONAN_HOME%\konan\lib"

set "HELPERS_JAR=%KONAN_LIB%\helpers.jar"
set "INTEROP_INDEXER_JAR=%KONAN_LIB%\Indexer.jar"
set "INTEROP_RUNTIME_JAR=%KONAN_LIB%\Runtime.jar"
set "KLIB_JAR=%KONAN_LIB%\klib.jar"
set "KONAN_JAR=%KONAN_LIB%\backend.native.jar"
set "KOTLIN_JAR=%KONAN_LIB%\kotlin-compiler.jar"
set "STUB_GENERATOR_JAR=%KONAN_LIB%\StubGenerator.jar"
set "UTILITIES_JAR=%KONAN_LIB%\utilities.jar"

set "KONAN_CLASSPATH=%KOTLIN_JAR%;%INTEROP_RUNTIME_JAR%;%KONAN_JAR%;%STUB_GENERATOR_JAR%;%INTEROP_INDEXER_JAR%;%HELPERS_JAR%;%KLIB_JAR%;%UTILITIES_JAR%"

set JAVA_OPTS=-ea ^
    -Xmx3G ^
    "-Djava.library.path=%NATIVE_LIB%" ^
    "-Dkonan.home=%_KONAN_HOME%" ^
    -Dfile.encoding=UTF-8

set LIBCLANG_DISABLE_CRASH_RECOVERY=1

"%_JAVACMD%" %JAVA_OPTS% %JAVA_ARGS% -cp "%KONAN_CLASSPATH%" %_TOOL_CLASS% %TOOL_NAME% %KONAN_ARGS%

exit /b %ERRORLEVEL%
goto end

rem ##########################################################################
rem # subroutines

:set_home
  set _BIN_DIR=
  for %%i in (%~sf0) do set _BIN_DIR=%_BIN_DIR%%%~dpsi
  set _KONAN_HOME=%_BIN_DIR%..
goto :eof

:set_path
  rem libclang.dll is dynamically linked and thus requires correct PATH to be loaded.
  rem TODO: remove this hack.
  set "PATH=%_KONAN_HOME%\dependencies\msys2-mingw-w64-x86_64-gcc-6.3.0-clang-llvm-3.9.1-windows-x86-64\bin;%PATH%"
goto :eof

:end
endlocal

