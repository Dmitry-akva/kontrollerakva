@echo off
setlocal enabledelayedexpansion

REM Имя workflow
set WORKFLOW=main.yml

REM Интервал обновления (секунды)
set INTERVAL=10

:loop
cls
echo ==============================
echo Последний запуск workflow "%WORKFLOW%"
echo ==============================

REM Получаем databaseId последнего запуска
for /f "tokens=*" %%A in ('.\gh.exe run list --workflow %WORKFLOW% --limit 1 --json databaseId --jq ".[0].databaseId"') do (
    set RUNID=%%A
)

if defined RUNID (
    echo Run ID: !RUNID!
    echo.
    REM Выводим логи последнего запуска
    .\gh.exe run view !RUNID! --log
) else (
    echo Запусков ещё нет.
)

REM Ждем заданный интервал
timeout /t %INTERVAL% /nobreak >nul
goto loop