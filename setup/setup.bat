@echo off
setlocal

echo === Installing WireGuard silently ===
powershell -Command "Start-Process msiexec.exe -ArgumentList '/i https://download.wireguard.com/windows-client/wireguard-installer.exe /quiet /norestart' -Wait"

echo === Creating VPN folder ===
mkdir "%~dp0localvpn" >nul 2>&1
cd "%~dp0localvpn"

echo === Generating private key ===
"%ProgramFiles%\WireGuard\wg.exe" genkey > privatekey
set /p PRIV=<privatekey

echo === Generating public key ===
echo %PRIV% | "%ProgramFiles%\WireGuard\wg.exe" pubkey > publickey

echo === Creating invisible local VPN config ===
(
echo [Interface]
echo PrivateKey = %PRIV%
echo Address = 10.0.0.1/24
echo ListenPort = 51820
echo DNS = 1.1.1.1
echo
echo # No peers - local-only tunnel
) > localvpn.conf

echo === Setup complete ===
echo Use file start.bat to start the invisible VPN.
pause
