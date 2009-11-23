@ECHO OFF

SET INSTALL_BUILD_DIR=%~dp0
REM SET FRAMEWORK_PATH="C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727"
SET FRAMEWORK_PATH="C:\Windows\Microsoft.NET\Framework\v3.5"
SET MSBUILD_OPTIONS=

SET MAKENSIS="C:\Program Files\NSIS\makensis.exe"
IF NOT EXIST %MAKENSIS% SET MAKENSIS="C:\Program Files (x86)\NSIS\makensis.exe"

ECHO *********************************************
ECHO *                                           *
ECHO *   Windar Debug Builder.                   *
ECHO *                                           *
ECHO *********************************************
ECHO.

ECHO.
ECHO *********************************************
ECHO *                                           *
ECHO *   Cleaning solution.                      *
ECHO *                                           *
ECHO *********************************************
ECHO.
CD %INSTALL_BUILD_DIR%
CALL clean.bat

ECHO.
ECHO *********************************************
ECHO *                                           *
ECHO *   Build and Copy Erlini utility.          *
ECHO *                                           *
ECHO *********************************************
ECHO.

SET BUILD_TEMP="%INSTALL_BUILD_DIR%Temp\"
IF NOT EXIST %BUILD_TEMP% MKDIR %BUILD_TEMP%

CD %INSTALL_BUILD_DIR%Utils\erlini
%FRAMEWORK_PATH%\MSBuild %MSBUILD_OPTIONS% erlini.sln /v:Quiet /t:Rebuild /p:Configuration=Release
IF NOT %ERRORLEVEL% == 0 GOTO BUILD_ERROR

CD %INSTALL_BUILD_DIR%Utils\erlini\bin\Debug
@ECHO ON
COPY erlini.exe %BUILD_TEMP%
@ECHO OFF

ECHO.
ECHO *********************************************
ECHO *                                           *
ECHO *   Building solution.                      *
ECHO *                                           *
ECHO *********************************************
ECHO.
CD %INSTALL_BUILD_DIR%..
%FRAMEWORK_PATH%\MSBuild %MSBUILD_OPTIONS% Windar.sln /v:Quiet /t:Rebuild /p:Configuration=Debug
IF NOT %ERRORLEVEL% == 0 GOTO BUILD_ERROR

ECHO.
ECHO *********************************************
ECHO *                                           *
ECHO *   Copy build product to temp folder.      *
ECHO *                                           *
ECHO *********************************************
ECHO.
CD %INSTALL_BUILD_DIR%..\TrayApp\bin\Debug

ECHO ______________________________
ECHO Windar application components:
@ECHO ON
COPY Windar.exe %BUILD_TEMP%
COPY Windar.Common.dll %BUILD_TEMP%
COPY Windar.PlaydarController.dll %BUILD_TEMP%
COPY Windar.PluginAPI.dll %BUILD_TEMP%
@ECHO OFF

ECHO.
ECHO ______________________
ECHO Debug build PDB files:
@ECHO ON
COPY Windar.pdb %BUILD_TEMP%
COPY Windar.Common.pdb %BUILD_TEMP%
COPY Windar.PlaydarController.pdb %BUILD_TEMP%
COPY Windar.PluginAPI.pdb %BUILD_TEMP%
@ECHO OFF

ECHO.
ECHO ___________
ECHO Other libs:
@ECHO ON
COPY log4net.dll %BUILD_TEMP%
@ECHO OFF

ECHO.
ECHO __________________
ECHO Configuration file:
CD %INSTALL_BUILD_DIR%..\bin\Debug
@ECHO ON
COPY Windar.exe.config %BUILD_TEMP%
@ECHO OFF

ECHO.
ECHO *********************************************
ECHO *                                           *
ECHO *   Building the NSIS installer package.    *
ECHO *                                           *
ECHO *********************************************
ECHO.
CD %INSTALL_BUILD_DIR%..\Installer
%MAKENSIS% windar_debug.nsi
IF NOT %ERRORLEVEL% == 0 GOTO NSIS_ERROR

ECHO.
ECHO *********************************************
ECHO *                                           *
ECHO *   Windar Debug Build Success.             *
ECHO *                                           *
ECHO *********************************************
CD %INSTALL_BUILD_DIR%
GOTO END_SCRIPT

:BUILD_ERROR
ECHO.
ECHO ____________________________________
ECHO BATCH SCRIPT QUIT DUE TO BUILD ERROR (%ERRORLEVEL%)
GOTO END_SCRIPT

:NSIS_ERROR
ECHO.
ECHO ___________________________________
ECHO BATCH SCRIPT QUIT DUE TO NSIS ERROR (%ERRORLEVEL%)
GOTO END_SCRIPT

:END_SCRIPT