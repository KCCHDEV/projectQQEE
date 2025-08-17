@echo off
echo ๐€ Starting Pet Food Shop...
docker-compose up -d
echo โ… Shop started at http://localhost:8000
start http://localhost:8000
pause
