@echo off
chcp 65001 >nul
setlocal

echo ===============================
echo 🚀 Auto Push + Update Release
echo ===============================

REM === Настройки ===
set TAG=v1.0.0
set WORKFLOW_NAME=Build ESP8266 Sketch
set WAIT_LOG=10
set MAX_ATTEMPTS_LOG=30

REM === 1. Добавляем все изменения ===
git add .

REM === 2. Коммит ===
set /p MSG="Введите комментарий коммита: "
if "%MSG%"=="" set MSG=Auto update
git commit -m "%MSG%"

REM === 3. Перезаписываем тег на новый коммит ===
git tag -f %TAG%
git push origin main
git push origin -f %TAG%

echo.
echo ✅ Push завершён. Ждём сборку и появление build-log.txt в релизе.
echo.

REM === 4. Ждём, пока build-log.txt появится в релизе ===
set ATTEMPT_LOG=0
:WAIT_LOG
set /a ATTEMPT_LOG+=1

REM Скачиваем build-log.txt в текущую папку
gh release download %TAG% --pattern "build-log.txt" --dir . >nul 2>&1

REM Проверяем, что файл существует и не пустой
if exist build-log.txt (
    for %%i in (build-log.txt) do set FILESIZE=%%~zi
    if %FILESIZE% GTR 0 (
        echo ✅ build-log.txt загружен и не пустой
        goto SHOW_LOG
    )
)

REM Прерываем после максимального количества попыток
if %ATTEMPT_LOG% GEQ %MAX_ATTEMPTS_LOG (
    echo ❌ build-log.txt не удалось получить после ожидания
    pause
    exit /b
)

echo ⏳ build-log.txt ещё не готов, ждём %WAIT_LOG% секунд...
timeout /t %WAIT_LOG% >nul
goto WAIT_LOG

:SHOW_LOG
echo.
echo ⏬ Лог сборки:
type build-log.txt
echo.

pause