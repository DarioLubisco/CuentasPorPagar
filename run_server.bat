@echo off
cd /d C:\source\cuentasporpagarDev
call .venv\Scripts\activate
uvicorn main:app --host 0.0.0.0 --port 8081
