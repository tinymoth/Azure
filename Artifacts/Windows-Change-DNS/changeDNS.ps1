Param(
  [string]$DCName 
)

cd $($PSScriptRoot)

Get-NetAdapter -Physical | 
% {Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses (
[System.Net.Dns]::GetHostAddresses($DCName).IPAddressToString) -WhatIf}