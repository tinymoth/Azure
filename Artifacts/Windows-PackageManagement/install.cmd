@echo OFF
setlocal

rem PowerShell PackageManagement installation 
rem https://www.microsoft.com/en-us/download/details.aspx?id=51451
rem 6.3 9600 Windows Server 2012 R2
rem 6.3 9600 Windows 8.1 Pro
rem 6.3 9600 Windows 8.1 Enterprise
rem 6.2 9200 Windows Server 2012
rem 6.1 7601 Windows 7 SP1
rem 6.1 7601 Windows Server 2008 R2 SP1

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
  call PackageManagement_x86.msi /quiet /norestart
 ) else (
  call PackageManagement_x64.msi /quiet /norestart
 )
) else (
 if %CURRENTVERSION%==6.2 (
  if %TARGETTYPE%==SERVER (
   call PackageManagement_x64.msi /quiet /norestart
  ) else (
   echo Not Supported on Windows 8. Please upgrade to 8.1
  )
 ) else (
  if %CURRENTVERSION%==6.3 (
	 if %OSVERSION%==32BIT (
	  call PackageManagement_x86.msi /quiet /norestart
	 ) else (
	  call PackageManagement_x64.msi /quiet /norestart
	 )
  ) else (
   echo Not Supported OS. Please check https://www.microsoft.com/en-us/download/details.aspx?id=51451
  )
 )
)

REM ErrorLevel means "The requested operation is successful. Changes will not be effective until the system is rebooted."
if %ERRORLEVEL% == 3010 (
  shutdown.exe /r /t 00
)