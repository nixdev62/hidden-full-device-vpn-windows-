@echo off
setlocal

echo Checking WireGuard installation...
if exist "%ProgramFiles%\WireGuard\wg.exe" (
    echo WireGuard already installed.
) else (
    echo Installing WireGuard silently...
    powershell -Command "Start-Process msiexec.exe -ArgumentList '/i https://download.wireguard.com/windows-client/wireguard-installer.exe /quiet /norestart' -Wait"
)

echo Preparing VPN folder...
mkdir "%~dp0localvpn" >nul 2>&1
cd "%~dp0localvpn"

if exist privatekey (
    echo Keys already exist.
) else (
    echo Generating private key...
    "%ProgramFiles%\WireGuard\wg.exe" genkey > privatekey
)

set /p PRIV=<privatekey

if exist publickey (
    echo Public key already exists.
) else (
    echo %PRIV% | "%ProgramFiles%\WireGuard\wg.exe" pubkey > publickey
)

echo Creating config...
(
echo [Interface]
echo PrivateKey = %PRIV%
echo Address = 10.0.0.1/24
echo ListenPort = 51820
echo DNS = 1.1.1.1
echo
echo # No peers - local only
) > localvpn.conf

echo.
set /p MODE=Do you want the VPN to stay after terminal closes? (Y/N): 

if /I "%MODE%"=="Y" goto PERMANENT
if /I "%MODE%"=="N" goto TEMPORARY

echo Invalid choice. Exiting.
exit /b

:PERMANENT
echo Setting up permanent VPN service...
"%ProgramFiles%\WireGuard\wireguard.exe" /installtunnelservice "%~dp0localvpn\localvpn.conf"
net start WireGuardTunnel$localvpn
echo Permanent VPN active. It will stay on after closing this window.
pause
exit /b

:TEMPORARY
echo Starting invisible temporary VPN...
taskkill /IM wireguard.exe /F >nul 2>&1
"%ProgramFiles%\WireGuard\wireguard.exe" /tunnel "%~dp0localvpn\localvpn.conf"
echo VPN active. Close this window to stop it.
pause
exit /b
