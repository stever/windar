;*************************************************************************
; DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
;
; Copyright (C) 2009, 2010 Steven Robertson <steve@playnode.org>
;
; Windar: Playdar for Windows
;
; Windar is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 2 of the License, or
; (at your option) any later version.
;
; Windar is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;************************************************************************/

;-----------------------------------------------------------------------------
;Get version information from Windar exe.
;-----------------------------------------------------------------------------
!system "get_version.exe"
!include "version.txt"
!define VERSION "${VER_MAJOR}.${VER_MINOR}.${VER_BUILD}"

;-----------------------------------------------------------------------------
;Some installer script options (comment-out options not required)
;-----------------------------------------------------------------------------
!define OPTION_DEBUG_BUILD
!define OPTION_BUNDLE_C_REDIST
!define OPTION_SECTION_SC_START_MENU
!define OPTION_SECTION_SC_START_MENU_STARTUP
!define OPTION_SECTION_SC_DESKTOP
!define OPTION_SECTION_SC_QUICK_LAUNCH
!define OPTION_FINISHPAGE
!define OPTION_FINISHPAGE_LAUNCHER
!define OPTION_FINISHPAGE_RELEASE_NOTES

;-----------------------------------------------------------------------------
;Other required definitions.
;-----------------------------------------------------------------------------
!define REDIST_DLL_VERSION 9.0.21022.8

;-----------------------------------------------------------------------------
;Initial installer setup and definitions.
;-----------------------------------------------------------------------------
Name "Windar"
Caption "Playdar for Windows"
BrandingText "www.windar.org"
OutFile "windar-${VERSION}.exe"
InstallDir "$PROGRAMFILES\Windar"
InstallDirRegKey HKCU "Software\Windar" ""
InstType Standard
InstType Full
InstType Minimal
SetCompressor /SOLID lzma
RequestExecutionLevel admin
ReserveFile windar.ini

;-----------------------------------------------------------------------------
;Redistributable installer definitions.
;-----------------------------------------------------------------------------
!define VCRUNTIME_SETUP_NAME "vcredist_x86.exe"
!define NETFRAMEWORK20_SETUP_NAME "dotnetfx.exe"
!define NETFRAMEWORK20_DOWNLOAD_LOCATION "http://download.microsoft.com/download/5/6/7/567758a3-759e-473e-bf8f-52154438565a/${NETFRAMEWORK20_SETUP_NAME}"
!define DOWNLOAD_FAILED_MSG "Download of system components failed. Possible \
   reasons include:$\n$\n1.   You canceled the installation$\n$\n2.   You do \
   not have an Internet connection right now. Please connect to the Internet \
   and run the installation again.$\n$\n3.   The connection to the server \
   timed out. Please try running the installation again.$\n$\n3.   Technical \
   issue with automatic download and/or installation. Please attempt to \
   download and install the required component manually, or temporarily \
   disable Internet security software (such as firewall) which may be interfering."

;-----------------------------------------------------------------------------
;Include some required header files.
;-----------------------------------------------------------------------------
!include MUI.nsh ;Provides modern user interface.
!include WordFunc.nsh ;Used by VersionCompare macro function.
!include WinVer.nsh ;Windows version detection.
!include Memento.nsh ;Remember user selections.

;-----------------------------------------------------------------------------
;Required macros.
;-----------------------------------------------------------------------------
!insertmacro VersionCompare

;-----------------------------------------------------------------------------
;Memento selections stored in registry.
;-----------------------------------------------------------------------------
!define MEMENTO_REGISTRY_ROOT HKLM
!define MEMENTO_REGISTRY_KEY Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar
                
;-----------------------------------------------------------------------------
;Modern User Interface (MUI) defintions and setup.
;-----------------------------------------------------------------------------
!define MUI_ABORTWARNING
!define MUI_ICON installer.ico
!define MUI_UNICON installer.ico
!define MUI_WELCOMEFINISHPAGE_BITMAP welcome.bmp
!define MUI_WELCOMEPAGE_TITLE "Windar ${VERSION} Setup\rInstaller Build Revision ${VER_REVISION}"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation.\r\n\r\n$_CLICK"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP page_header.bmp
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_FINISHPAGE_TITLE "Windar Install Completed"
!define MUI_FINISHPAGE_LINK "Click here to visit the Playdar website."
!define MUI_FINISHPAGE_LINK_LOCATION "http://www.playdar.org/"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!ifdef OPTION_FINISHPAGE_RELEASE_NOTES
   !define MUI_FINISHPAGE_SHOWREADME
   !define MUI_FINISHPAGE_SHOWREADME_TEXT "Show release notes"
   !define MUI_FINISHPAGE_SHOWREADME_FUNCTION ShowReleaseNotes
!endif
!ifdef OPTION_FINISHPAGE_LAUNCHER
   !define MUI_FINISHPAGE_RUN "$INSTDIR\Windar.exe"
!endif

;-----------------------------------------------------------------------------
;Page macros.
;-----------------------------------------------------------------------------
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.rtf"
Page custom PageReinstall PageLeaveReinstall
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!ifdef OPTION_FINISHPAGE
   !insertmacro MUI_PAGE_FINISH
   !insertmacro MUI_UNPAGE_CONFIRM
!endif
!insertmacro MUI_UNPAGE_INSTFILES

;-----------------------------------------------------------------------------
;Other MUI macros.
;-----------------------------------------------------------------------------
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

##############################################################################
#                                                                            #
#   MISC. FUNCTIONS                                                          #
#                                                                            #
##############################################################################

!ifdef OPTION_FINISHPAGE_RELEASE_NOTES
   Function ShowReleaseNotes
      ExecShell "open" "$INSTDIR\README.txt"
   FunctionEnd
!endif

##############################################################################
#                                                                            #
#   RE-INSTALLER FUNCTIONS                                                   #
#                                                                            #
##############################################################################

Function PageReinstall
   ReadRegStr $R0 HKLM "Software\Windar" ""
   StrCmp $R0 "" 0 +2
   Abort

   ;Detect version
   ReadRegDWORD $R0 HKLM "Software\Windar" "VersionMajor"
   IntCmp $R0 ${VER_MAJOR} minor_check new_version older_version
   minor_check:
      ReadRegDWORD $R0 HKLM "Software\Windar" "VersionMinor"
      IntCmp $R0 ${VER_MINOR} build_check new_version older_version
   build_check:
      ReadRegDWORD $R0 HKLM "Software\Windar" "VersionBuild"
      IntCmp $R0 ${VER_BUILD} revision_check new_version older_version
   revision_check:
      ReadRegDWORD $R0 HKLM "Software\Windar" "VersionRevision"
      IntCmp $R0 ${VER_REVISION} same_version new_version older_version

   new_version:
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 1" "Text" "An older version of Windar is installed on your system. It is recommended that you uninstall the current version before installing. Select the operation you want to perform and click Next to continue."
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 2" "Text" "Uninstall before installing"
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 3" "Text" "Do not uninstall"
      !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose how you want to install Windar."
      StrCpy $R0 "1"
      Goto reinst_start

   older_version:
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 1" "Text" "A newer version of Windar is already installed! It is not recommended that you install an older version. If you really want to install this older version, it is better to uninstall the current version first. Select the operation you want to perform and click Next to continue."
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 2" "Text" "Uninstall before installing"
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 3" "Text" "Do not uninstall"
      !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose how you want to install Windar."
      StrCpy $R0 "1"
      Goto reinst_start

   same_version:
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 1" "Text" "Windar ${VERSION} is already installed.\r\nSelect the operation you want to perform and click Next to continue."
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 2" "Text" "Add/Reinstall components"
      !insertmacro MUI_INSTALLOPTIONS_WRITE "windar.ini" "Field 3" "Text" "Uninstall Windar"
      !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose the maintenance option to perform."
      StrCpy $R0 "2"

   reinst_start:
      !insertmacro MUI_INSTALLOPTIONS_DISPLAY "windar.ini"
FunctionEnd

Function PageLeaveReinstall
   !insertmacro MUI_INSTALLOPTIONS_READ $R1 "windar.ini" "Field 2" "State"
   StrCmp $R0 "1" 0 +2
   StrCmp $R1 "1" reinst_uninstall reinst_done
   StrCmp $R0 "2" 0 +3
   StrCmp $R1 "1" reinst_done reinst_uninstall
   reinst_uninstall:
      ReadRegStr $R1 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "UninstallString"
      HideWindow
      ClearErrors
      ExecWait '$R1 _?=$INSTDIR'
      IfErrors no_remove_uninstaller
      IfFileExists "$INSTDIR\Windar.exe" no_remove_uninstaller
      Delete $R1
      RMDir $INSTDIR
   no_remove_uninstaller:
      StrCmp $R0 "2" 0 +2
      Quit
      BringToFront
   reinst_done:
FunctionEnd

##############################################################################
#                                                                            #
#   C REDISTRIBUTABLE INSTALLER                                              #
#                                                                            #
##############################################################################

!ifdef OPTION_BUNDLE_C_REDIST
   Function IsDllVersionGoodEnough
      IntCmp 0 $R0 normal0 normal0 negative0
      normal0: 
         IntOp $R2 $R0 >> 16
         Goto continue0
      negative0:
         IntOp $R2 $R0 & 0x7FFF0000
         IntOp $R2 $R2 >> 16
         IntOp $R2 $R2 | 0x8000
      continue0:		
         IntOp $R3 $R0 & 0x0000FFFF
         IntCmp 0 $R1 normal1 normal1 negative1
      normal1: 
         IntOp $R4 $R1 >> 16
         Goto continue1
      negative1:
         IntOp $R4 $R1 & 0x7FFF0000
         IntOp $R4 $R4 >> 16
         IntOp $R4 $R4 | 0x8000
      continue1:		
         IntOp $R5 $R1 & 0x0000FFFF
         StrCpy $2 "$R2.$R3.$R4.$R5"
         ${VersionCompare} $2 ${REDIST_DLL_VERSION} $R0
         Return
   FunctionEnd

   Function RequireCRedist
      IfFileExists $SYSDIR\msvcr90.dll MaybeFoundInSystem
      SearchSxs:	
         FindFirst $0 $1 $WINDIR\WinSxS\x86*
      Loop:
         StrCmp $1 "" NotFound
         IfFileExists $WINDIR\WinSxS\$1\msvcr90.dll MaybeFoundInSxs
         FindNext $0 $1
         Goto Loop
      MaybeFoundInSxs:
         GetDllVersion $WINDIR\WinSxS\$1\msvcr90.dll $R0 $R1
         Call IsDllVersionGoodEnough
         FindNext $0 $1
         IntCmp 2 $R0 Loop
         Goto Found 
      MaybeFoundInSystem:
         GetDllVersion $SYSDIR\msvcr90.dll $R0 $R1
         Call IsDllVersionGoodEnough
         IntCmp 2 $R0 SearchSxS
      Found:
         Return
      NotFound:
         MessageBox MB_ICONINFORMATION|MB_OK "Windar Setup determined that you \
            do not have the Microsoft C runtime version required. It will now be installed."
         SetOutPath "$INSTDIR"
         File "Payload\${VCRUNTIME_SETUP_NAME}"
         ExecWait '"$INSTDIR\${VCRUNTIME_SETUP_NAME}" /q:a /c:"VCREDI~1.EXE /q:a /c:""msiexec /i vcredist.msi /qb!"" "'
   FunctionEnd
!endif

##############################################################################
#                                                                            #
#   THE .NET FRAMEWORK INSTALLER                                             #
#                                                                            #
##############################################################################

Function GetDotNETVersion
   Push $0
   Push $1
   System::Call "mscoree::GetCORVersion(w .r0, i ${NSIS_MAX_STRLEN}, *i) i .r1 ?u"
   StrCmp $1 "error" 0 +2
      StrCpy $0 "not found"
   Pop $1
   Exch $0
FunctionEnd

Function RequireMicrosoftNET2
   DetailPrint "Checking .NET Framework and required version."

   ;Check for and install the .NET Framework redistributable if required.
   Call GetDotNETVersion
   Pop $0
   ${If} $0 == "not found"
      MessageBox MB_ICONINFORMATION|MB_OK "Windar Setup determined that you \
         do not have the Microsoft .NET Framework version 2.0 installed on your \
         system. As this is a required component in order for Windar to function \
         properly it will now be installed."
      Call InstallNETFramework2
   ${Else}
      StrCpy $0 $0 "" 1 # skip "v"
      ${VersionCompare} $0 "2.0" $1
      ${If} $1 == 2
         MessageBox MB_ICONINFORMATION|MB_OK "Windar Setup determined that you \
            do not have the Microsoft .NET Framework version 2.0 installed on your \
            system. As this is a required component in order for Windar to function \
            properly it will now be installed."
         Call InstallNETFramework2
      ${EndIf}
   ${EndIf}
FunctionEnd

Function InstallNETFramework2
   DetailPrint "Installing .NET Framework 2.0"
   
   IfFileExists '${NETFRAMEWORK20_SETUP_NAME}' DOTNETFX_SUCCESS DOWNLOAD_NET_RUNTIME
   DOWNLOAD_NET_RUNTIME:
      NSISdl::download /TIMEOUT=30000 '${NETFRAMEWORK20_DOWNLOAD_LOCATION}' '${NETFRAMEWORK20_SETUP_NAME}'
      Pop $R0 ;Get the return value
      StrCmp $R0 "success" DOTNETFX_SUCCESS DOTNETFX_FAILURE
   USER_CANCELED:
      Quit
   DOTNETFX_FAILURE:
      MessageBox MB_ICONEXCLAMATION|MB_RETRYCANCEL '${DOWNLOAD_FAILED_MSG}' \
                 IDRETRY  DOWNLOAD_NET_RUNTIME \
                 IDCANCEL USER_CANCELED
   DOTNETFX_SUCCESS:
      ExecWait '"${NETFRAMEWORK20_SETUP_NAME}" /q:a /c:"install /l /q"'
FunctionEnd

##############################################################################
#                                                                            #
#   INSTALLER SECTIONS                                                       #
#                                                                            #
##############################################################################

Section "Playdar-core & Windar." SEC_WINDAR
   SectionIn 1 2 3 RO

   Call RequireCRedist
   
   DetailPrint "Installing core Playdar and minimum Erlang components."
   
   ;Check for and offer to kill epmd.exe process.
   StrCpy $0 "epmd.exe"
   DetailPrint "Searching for processes called '$0'"
   KillProc::FindProcesses
   StrCmp $1 "-1" epmd_error
   StrCmp $0 "0" epmd_completed
   Sleep 1500   
   MessageBox MB_YESNO|MB_ICONEXCLAMATION \
     "Found $0 epmd.exe process(s) which may need to be stopped.$\nDo you want the installer to stop these for you?" \
     IDYES epmd_killproc IDNO epmd_completed    
   epmd_killproc:
      StrCpy $0 "epmd.exe"
      DetailPrint "Killing all processes called '$0'"
      KillProc::KillProcesses
      StrCmp $1 "-1" epmd_error
      DetailPrint "Killed $0 processes, faild to kill $1 processes."
   epmd_error:
   epmd_completed:
      
   ;Check for and offer to kill erl.exe process.
   StrCpy $0 "erl.exe"
   DetailPrint "Searching for processes called '$0'"
   KillProc::FindProcesses
   StrCmp $1 "-1" erl_error
   StrCmp $0 "0" erl_completed
   Sleep 1500   
   MessageBox MB_YESNO|MB_ICONEXCLAMATION \
     "Found $0 erl.exe process(s) which may need to be stopped.$\nDo you want the installer to stop these for you?" \
     IDYES erl_killproc IDNO erl_completed    
   erl_killproc:
      StrCpy $0 "erl.exe"
      DetailPrint "Killing all processes called '$0'"
      KillProc::KillProcesses
      StrCmp $1 "-1" erl_error
      DetailPrint "Killed $0 processes, faild to kill $1 processes."
   erl_error:
   erl_completed:

   IfFileExists "$WINDIR\system32\libeay32.dll" openssl_lib_installed
      SetOutPath "$WINDIR\system32"
      File Payload\libeay32.dll
   openssl_lib_installed:
   
   ;Erlang and Playdar payload.
   SetOutPath "$INSTDIR"
   File /r Payload\minimerl
   File /r Payload\playdar

   ;Bat script to launch playdar-core in command window.
   SetOutPath "$INSTDIR\playdar"
   File Payload\playdar-core.bat

   ;Write the required erl.ini files.
   SetOutPath "$INSTDIR\minimerl\bin"
   File Temp\erlini.exe
   ExecWait '"$INSTDIR\minimerl\bin\erlini.exe"'
;SectionEnd

;Section "Windar Tray Application" SEC_WINDAR
;   SectionIn 1 2 3 RO

   ;Shutdown Windar if running.
   IfFileExists $INSTDIR\Windar.exe windar_installed windar_not_installed
   windar_installed:
      FileOpen $0 $INSTDIR\SHUTDOWN w
      FileWrite $0 "x"
      FileClose $0
      DetailPrint "Pausing to allow Windar to shutdown, if running."
      Sleep 3000
   windar_not_installed:
   
   Call RequireMicrosoftNET2

   DetailPrint "Installing the Windar application components."

   SetOutPath "$INSTDIR"

   ;Windar application components:
   File Temp\ErlangTerms.dll
   File Temp\Windar.exe
   File Temp\Windar.Common.dll
   File Temp\Windar.PlaydarDaemon.dll
   File Temp\Windar.PluginAPI.dll

   ;Configuration
   File Temp\Windar.exe.config

   !ifdef OPTION_DEBUG_BUILD
      ;Debug build PDB files:
      File Temp\ErlangTerms.pdb
      File Temp\Windar.pdb
      File Temp\Windar.Common.pdb
      File Temp\Windar.PlaydarDaemon.pdb
      File Temp\Windar.PluginAPI.pdb
   !endif
   
   ;Other libs:
   File Temp\log4net.dll

   ;License & copyright files.
   File /oname=COPYING.txt ..\COPYING
   File /oname=LICENSE.txt ..\LICENSE
   File /oname=LICENSE-OPENSSL.txt ..\LICENSE-OPENSSL
SectionEnd

!ifdef OPTION_SECTION_SC_START_MENU_STARTUP
   ${MementoSection} "Auto-start on system startup." SEC_STARTUP_FOLDER
      SectionIn 1 2
      DetailPrint "Adding shortcut in Startup folder to start Windar on login."
      CreateShortCut "$SMPROGRAMS\Startup\Windar.lnk" "$INSTDIR\Windar.exe"
   ${MementoSectionEnd}
!endif

SectionGroup "Additional shortcuts."

!ifdef OPTION_SECTION_SC_START_MENU
   ${MementoSection} "Start Menu Program Group Shortcuts" SEC_START_MENU
      SectionIn 1 2

      DetailPrint "Adding shortcuts for the Windar program group to the Start Menu."

      RMDir /r "$SMPROGRAMS\Windar"
      CreateDirectory "$SMPROGRAMS\Windar"
      CreateShortCut "$SMPROGRAMS\Windar\Windar.lnk" "$INSTDIR\Windar.exe"
      CreateShortCut "$SMPROGRAMS\Windar\COPYING.lnk" "$INSTDIR\COPYING.txt"
      CreateShortCut "$SMPROGRAMS\Windar\LICENSE.lnk" "$INSTDIR\LICENSE.txt"
      CreateShortCut "$SMPROGRAMS\Windar\LICENSE-OPENSSL.lnk" "$INSTDIR\LICENSE-OPENSSL.txt"      
      CreateShortCut "$SMPROGRAMS\Windar\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
   ${MementoSectionEnd}
!endif

!ifdef OPTION_SECTION_SC_DESKTOP
   ${MementoUnselectedSection} "Desktop Shortcut" SEC_DESKTOP
      SectionIn 2
      DetailPrint "Creating Desktop Shortcuts"
      CreateShortCut "$DESKTOP\Windar.lnk" "$INSTDIR\Windar.exe"
   ${MementoSectionEnd}
!endif

!ifdef OPTION_SECTION_SC_QUICK_LAUNCH
   ${MementoSection} "Quick Launch Shortcut" SEC_QUICK_LAUNCH
      SectionIn 1 2
      DetailPrint "Creating Quick Launch Shortcut"
      CreateShortCut "$QUICKLAUNCH\Windar.lnk" "$INSTDIR\Windar.exe"
   ${MementoSectionEnd}
!endif

SectionGroupEnd

${MementoSection} "Resolver test & stream player." SEC_PLAYER
   SectionIn 1 2
   DetailPrint "Installing MPlayer and the Player plugin for Windar."

   SetOutPath "$INSTDIR"
   File /r Payload\mplayer
   File Temp\Windar.PlayerPlugin.dll
   !ifdef OPTION_DEBUG_BUILD
      File Temp\Windar.PlayerPlugin.pdb
   !endif
   File Temp\Newtonsoft.Json.Net20.dll
${MementoSectionEnd}

${MementoUnselectedSection} "Scrobbler support." SEC_SCROBBLER
   SectionIn 2
   DetailPrint "Installing the scrobbler module and Windar plugin."

   SetOutPath "$INSTDIR\playdar\playdar_modules"
   File /r Payload\playdar_modules\audioscrobbler
   SetOutPath "$INSTDIR"
   File Temp\Windar.ScrobblerPlugin.dll
   !ifdef OPTION_DEBUG_BUILD
      File Temp\Windar.ScrobblerPlugin.pdb
   !endif
${MementoSectionEnd}

SectionGroup "Additional resolvers."

#${MementoSection} "Amie Street" SEC_AMIESTREET_RESOLVER
#   SectionIn 2
#   DetailPrint "Installing resolver for Amie Street."
#   SetOutPath "$INSTDIR\playdar\contrib"
#   File /r Payload\playdar_scripts\amiestreet
#${MementoSectionEnd}

${MementoUnselectedSection} "AOL Music Index" SEC_AOL_RESOLVER
   SectionIn 2
   DetailPrint "Installing resolver for the AOL Music Index."
   SetOutPath "$INSTDIR\playdar\playdar_modules"
   File /r Payload\playdar_modules\aolmusic
${MementoSectionEnd}

${MementoUnselectedSection} "Audiofarm.org" SEC_AUDIOFARM_RESOLVER
   SectionIn 2
   DetailPrint "Installing resolver for Audiofarm."
   SetOutPath "$INSTDIR\playdar\contrib"
   File /r Payload\playdar_scripts\audiofarm
${MementoSectionEnd}

${MementoUnselectedSection} "The Echo Nest" SEC_ECHONEST_RESOLVER
   SectionIn 2
   DetailPrint "Installing resolver for The Echo Nest."
   SetOutPath "$INSTDIR\playdar\contrib"
   File /r Payload\playdar_scripts\echonest
${MementoSectionEnd}

${MementoUnselectedSection} "Jamendo" SEC_JAMENDO_RESOLVER
   SectionIn 2
   DetailPrint "Installing resolver for Jamendo."
   SetOutPath "$INSTDIR\playdar\playdar_modules"
   File /r Payload\playdar_modules\jamendo
${MementoSectionEnd}

${MementoUnselectedSection} "Magnatune" SEC_MAGNATUNE_RESOLVER
   SectionIn 2
   DetailPrint "Installing resolver for Magnatune."
   SetOutPath "$INSTDIR\playdar\playdar_modules"
   File /r Payload\playdar_modules\magnatune
${MementoSectionEnd}

${MementoUnselectedSection} "MP3tunes" SEC_MP3TUNES_RESOLVER
   SectionIn 2
   DetailPrint "Installing resolver for MP3tunes."
   SetOutPath "$INSTDIR\playdar\contrib"
   File /r Payload\playdar_scripts\mp3tunes
   SetOutPath "$INSTDIR"
   File Temp\Windar.MP3tunesPlugin.dll
   !ifdef OPTION_DEBUG_BUILD
      File Temp\Windar.MP3tunesPlugin.pdb
   !endif
${MementoSectionEnd}

${MementoUnselectedSection} "Napster" SEC_NAPSTER_RESOLVER
   SectionIn 2
   DetailPrint "Installing resolver for Napster."
   SetOutPath "$INSTDIR\playdar\contrib"
   File /r Payload\playdar_scripts\napster
   SetOutPath "$INSTDIR"
   File Temp\Windar.NapsterPlugin.dll
   !ifdef OPTION_DEBUG_BUILD
      File Temp\Windar.NapsterPlugin.pdb
   !endif
${MementoSectionEnd}

#${MementoUnselectedSection} "SoundCloud" SEC_SOUNDCLOUD_RESOLVER
#   SectionIn 2
#   DetailPrint "Installing resolver for SoundCloud."
#   SetOutPath "$INSTDIR\playdar\contrib"
#   File /r Payload\playdar_scripts\soundcloud
#${MementoSectionEnd}

SectionGroupEnd

${MementoSectionDone}

;Installer section descriptions
;--------------------------------
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

!insertmacro MUI_DESCRIPTION_TEXT ${SEC_WINDAR} "Playdar core, mini-Erlang & Windar tray application."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_PLAYER} "MPlayer and Player plugin for Windar."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_SCROBBLER} "Scrobbing support for Last.fm/audioscrobbler."
#!insertmacro MUI_DESCRIPTION_TEXT ${SEC_AMIESTREET_RESOLVER} "Amie Street resolver script."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_AUDIOFARM_RESOLVER} "Audiofarm.org resolver script."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_AOL_RESOLVER} "Resolves to web content in the AOL Music Index."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_ECHONEST_RESOLVER} "The Echo Nest resolver."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_JAMENDO_RESOLVER} "Resolver for free and legal music downloads on Jamendo."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_MAGNATUNE_RESOLVER} "Resolver for free content on Magnatune."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_MP3TUNES_RESOLVER} "Resolver for your MP3tunes locker. Requires a free or paid account."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC_NAPSTER_RESOLVER} "Resolver for Napster. Paid account has full streams, otherwise provides 30 second samples."
#!insertmacro MUI_DESCRIPTION_TEXT ${SEC_SOUNDCLOUD_RESOLVER} "SoundCloud resolver script."

!ifdef OPTION_SECTION_SC_START_MENU
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_START_MENU} "Windar program group, with shortcuts for Windar, info, and the Windar Uninstaller."
!endif

!ifdef OPTION_SECTION_SC_DESKTOP
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_DESKTOP} "Desktop shortcut for Windar."
!endif

!ifdef OPTION_SECTION_SC_QUICK_LAUNCH
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_QUICK_LAUNCH} "Quick Launch shortcut for Windar."
!endif

!ifdef OPTION_SECTION_SC_START_MENU_STARTUP
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_STARTUP_FOLDER} "Startup folder shortcut to start Windar on login."
!endif

!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section -post

   ;Remove the erlang ini writing utility. NOTE: Delete on this doesn't see to work.
   Delete '"$INSTDIR\minimerl\bin\erlini.exe"'
   
   ;Remove the redistributable installers.
   IfFileExists '"$INSTDIR\${VCRUNTIME_SETUP_NAME}"' 0 +2
      Delete '"$INSTDIR\${VCRUNTIME_SETUP_NAME}"'

   ;Uninstaller file.
   DetailPrint "Writing Uninstaller"
   WriteUninstaller $INSTDIR\Uninstall.exe

   ;Release notes.
   !ifdef OPTION_FINISHPAGE_RELEASE_NOTES
      DetailPrint "Writing Release Notes"
      SetOutPath "$INSTDIR"
      File /oname=README.txt ..\README.md
      IfFileExists "$SMPROGRAMS\Windar" 0 +2
         CreateShortCut "$SMPROGRAMS\Windar\README.lnk" "$INSTDIR\README.txt"
   !endif

   ;Registry keys required for installer version handling and uninstaller.
   DetailPrint "Writing Installer Registry Keys"

   ;Version numbers used to detect existing installation version for comparisson.
   WriteRegStr HKLM "Software\Windar" "" $INSTDIR
   WriteRegDWORD HKLM "Software\Windar" "VersionMajor" "${VER_MAJOR}"
   WriteRegDWORD HKLM "Software\Windar" "VersionMinor" "${VER_MINOR}"
   WriteRegDWORD HKLM "Software\Windar" "VersionRevision" "${VER_REVISION}"
   WriteRegDWORD HKLM "Software\Windar" "VersionBuild" "${VER_BUILD}"

   ;Add or Remove Programs entry.
   WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "UninstallString" '"$INSTDIR\Uninstall.exe"'
   WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "InstallLocation" "$INSTDIR"
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "DisplayName" "Windar"
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "DisplayIcon" "$INSTDIR\Uninstall.exe,0"
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "DisplayVersion" "${VERSION}"
   WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "VersionMajor" "${VER_MAJOR}"
   WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "VersionMinor" "${VER_MINOR}.${VER_REVISION}"
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "URLInfoAbout" "http://www.windar.org/"
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "HelpLink" "http://www.playdar.org/"
   WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "NoModify" "1"
   WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar" "NoRepair" "1"

   DetailPrint "Installation Complete"
SectionEnd

##############################################################################
#                                                                            #
#   UNINSTALLER SECTION                                                      #
#                                                                            #
##############################################################################

Section Uninstall

   IfFileExists $INSTDIR\Windar.exe windar_installed
      MessageBox MB_YESNO "It does not appear that Windar is installed in the directory '$INSTDIR'.$\r$\nContinue anyway (not recommended)?" IDYES windar_installed
      Abort "Uninstall aborted by user"

   windar_installed:

   ;Shutdown Windar if running.
   FileOpen $0 $INSTDIR\SHUTDOWN w
   FileWrite $0 "x"
   FileClose $0
   DetailPrint "Pausing to allow Windar to shutdown, if running."
   Sleep 3000

   ;Delete registry keys.
   DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Windar"
   DeleteRegValue HKLM "Software\Windar" "VersionBuild"
   DeleteRegValue HKLM "Software\Windar" "VersionMajor"
   DeleteRegValue HKLM "Software\Windar" "VersionMinor"
   DeleteRegValue HKLM "Software\Windar" "VersionRevision"
   DeleteRegValue HKLM "Software\Windar" ""
   DeleteRegKey HKLM "Software\Windar"

   ;Start menu shortcuts.
   !ifdef OPTION_SECTION_SC_START_MENU
      RMDir /r "$SMPROGRAMS\Windar"
   !endif

   ;Startup folder shortcut.
      IfFileExists "$SMPROGRAMS\Startup\Windar.lnk" 0 +2
         Delete "$SMPROGRAMS\Startup\Windar.lnk"   

   ;Desktop shortcut.
   !ifdef OPTION_SECTION_SC_DESKTOP
      IfFileExists "$DESKTOP\Windar.lnk" 0 +2
         Delete "$DESKTOP\Windar.lnk"
   !endif

   ;Quick Launch shortcut.
   !ifdef OPTION_SECTION_SC_QUICK_LAUNCH
      IfFileExists "$QUICKLAUNCH\Windar.lnk" 0 +2
         Delete "$QUICKLAUNCH\Windar.lnk"
   !endif

   RMDir /r $INSTDIR\minimerl
   RMDir /r $INSTDIR\playdar
   RMDir /r $INSTDIR
SectionEnd

##############################################################################
#                                                                            #
#   NSIS Event Handler Functions                                             #
#                                                                            #
##############################################################################

Function .onInit

   ;Prevent multiple instances.
   System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
   Pop $R0
   StrCmp $R0 0 +3
      MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
      Abort
   
   !insertmacro MUI_INSTALLOPTIONS_EXTRACT "windar.ini"
   
   ;Warn user if system is older than Windows XP.
   ${IfNot} ${AtLeastWinXP}
      MessageBox MB_OK "Unsupported on anything older than Windows XP."
      ;Quit
   ${EndIf}

   ;Remove Quick Launch option from Windows 7 as no longer applicable.
   ${IfNot} ${AtMostWinVista}
      SectionSetText ${SEC_QUICK_LAUNCH} "Quick Launch Shortcut (N/A)"
      SectionSetFlags ${SEC_QUICK_LAUNCH} ${SF_RO}
      SectionSetInstTypes ${SEC_QUICK_LAUNCH} 0
   ${EndIf}

   ${MementoSectionRestore}
   
FunctionEnd

Function .onInstSuccess

   ${MementoSectionSave}

FunctionEnd