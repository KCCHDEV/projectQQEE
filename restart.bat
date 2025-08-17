@echo off
echo ๐” Restarting Pet Food Shop...
docker-compose restart
echo โ… Shop restarted
start http://localhost:8000
pause
