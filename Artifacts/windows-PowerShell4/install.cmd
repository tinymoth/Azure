@echo OFF
setlocal

rem https://www.microsoft.com/en-us/download/details.aspx?id=40855
rem three installers. x32 client, x64 client (but not w8, which has same build/ver as server 2012), x64 server.
rem 
Rem Windows 7 SP1 [6.1][7600 or 7601]
rem  x64: Windows6.1-KB2819745-x64-MultiPkg.msu
rem  x86: Windows6.1-KB2819745-x86.msu
rem Windows Server 2008 R2 SP1 [6.1][7600 or 7601]
rem  x64: Windows6.1-KB2819745-x64-MultiPkg.msu
rem Windows 8 [6.2][9200]
rem  NOT SUPPORTED. Upgrade to 8.1
rem Windows Server 2012 [6.2][9200]
rem  x64: Windows8-RT-KB2799888-x64.msu

rem if 6.1
rem  if x86 Windows6.1-KB2819745-x86.msu
rem  if x64 Windows6.1-KB2819745-x64-MultiPkg.msu
rem if 6.2
rem  if server Windows8-RT-KB2799888-x64.msu
rem  if client NOT SUPPORTED


reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OSVERSION=32BIT || set OSVERSION=64BIT

reg Query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionId | find /i "server" > NUL && set TARGETTYPE=SERVER || set TARGETTYPE=CLIENT

for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild"') do set CURRENTBUILD=%%b

for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CurrentVersion"') do set CURRENTVERSION=%%b

echo Current Version: %CURRENTVERSION%
echo Current Build  : %CURRENTBUILD%
echo OS Version     : %OSVERSION%
echo Target Type    : %TARGETTYPE%

if %CURRENTVERSION%==6.1 (
 if %OSVERSION%==32BIT (
  call Windows6.1-KB2819745-x86.msu /quiet /norestart
 ) else (
  call Windows6.1-KB2819745-x64-MultiPkg.msu /quiet /norestart
 )
) else (
 if %CURRENTVERSION%==6.2 (
  if %TARGETTYPE%==SERVER (
   call Windows8-RT-KB2799888-x64.msu /quiet /norestart
  ) else (
   echo Not Supported on Windows 8. Please upgrade to 8.1
  )
 ) else (
  echo Not a supported OS. Windows 7, 2008 R2 or 2012 only.
 )
)

REM ErrorLevel means "The requested operation is successful. Changes will not be effective until the system is rebooted."
if %ERRORLEVEL% == 3010 (
  shutdown.exe /r /t 00
)