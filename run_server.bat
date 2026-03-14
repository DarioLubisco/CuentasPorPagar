@echo off
cd /d C:\source\CuentasPorPagar
call .venv\Scripts\activate
uvicorn main:app --host 0.0.0.0 --port 8080
