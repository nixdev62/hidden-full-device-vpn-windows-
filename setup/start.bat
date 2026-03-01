@echo off
title Invisible Local VPN (closes when window closes)

echo Starting invisible WireGuard tunnel...
taskkill /IM wireguard.exe /F >nul 2>&1

"%ProgramFiles%\WireGuard\wireguard.exe" /tunnel "%~dp0localvpn\localvpn.conf"

echo VPN active. Close this window to stop it.
pause
