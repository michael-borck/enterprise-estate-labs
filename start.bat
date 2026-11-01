@echo off
cd /d "%~dp0"
docker compose --profile m03 --profile m06 up -d
echo.
echo Enterprise estate is up.
echo   TLS proxy:  https://localhost:8443  (self-signed, expect a warning)
echo   HTTP proxy: http://localhost:8080
echo.
echo Open modules\module-06-web-tls\LAB-GUIDE.md
