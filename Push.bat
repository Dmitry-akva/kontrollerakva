@echo off
chcp 65001 >nul
setlocal

echo ===============================
echo 🚀 Auto Push + Update Release
echo ===============================

set TAG=v1.0.0
set WAIT_LOG=10
set MAX_ATTEMPTS_LOG=60  REM увеличиваем, чтобы хватило на компиляцию

REM === 1. Git add + commit + push + форс тег ===
git add .
set /p MSG="Введите комментарий коммита: "
if "%MSG%"=="" set MSG=Auto update
git commit -m "%MSG%"
git tag -f %TAG%
git push origin main
git push origin -f %TAG%

echo.
echo ✅ Push завершён. Ждём завершения компиляции и build-log.txt...
echo.

REM === 2. Цикл ожидания build-log.txt в релизе ===
set ATTEMPT_LOG=0
:WAIT_LOG
set /a ATTEMPT_LOG+=1

REM Скачиваем файл (перезаписывает каждый раз)
gh release download %TAG% --pattern "build-log.txt" --dir . >nul 2>&1

REM Проверяем размер файла
if exist build-log.txt (
    for %%i in (build-log.txt) do set FILESIZE=%%~zi
    if %FILESIZE% GTR 0 (
        echo ✅ build-log.txt загружен и не пустой
        goto SHOW_LOG
    )
)

if %ATTEMPT_LOG% GEQ %MAX_ATTEMPTS_LOG (
    echo ❌ build-log.txt так и не появился после ожидания.
    pause
    exit /b
)

echo ⏳ build-log.txt ещё пустой. Ждём %WAIT_LOG% секунд...
timeout /t %WAIT_LOG% >nul
goto WAIT_LOG

:SHOW_LOG
echo.
echo ⏬ Лог сборки:
type build-log.txt
echo.

pause