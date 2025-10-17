@echo off
chcp 65001 >nul
setlocal

echo ===============================
echo 🚀 Auto Push + Update Release
echo ===============================

REM === Настройки ===
set TAG=v1.0.0
set WORKFLOW_NAME=Build ESP8266 Sketch
set WAIT_TIME=10

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
echo ===============================
echo ✅ Push complete!
echo Тег %TAG% перезаписан на новый коммит.
echo GitHub Actions соберёт и обновит релиз.
echo ===============================
echo.

REM === 4. Ждём появления workflow ===
:WAIT_WORKFLOW
echo ⏳ Ждём старт workflow...
timeout /t %WAIT_TIME% >nul

REM 1. Получаем ID последнего workflow для тега
for /f "tokens=*" %%i in ('gh run list --workflow "Build ESP8266 Sketch" --branch refs/tags/%TAG% --limit 1 --json databaseId -q ".[0].databaseId"') do set RUN_ID=%%i

REM 2. Проверяем, что нашли ID
if "%RUN_ID%"=="" (
    echo ❌ Workflow для тега %TAG% не найден
    pause
    exit /b
)

REM 3. Ждём завершения workflow
:WAIT_COMPLETION
for /f "tokens=*" %%i in ('gh run view %RUN_ID% --json status,conclusion -q ".status + \",\" + .conclusion"') do set STATUS_CONC=%%i
for /f "tokens=1,2 delims=," %%a in ("%STATUS_CONC%") do (
    set STATUS=%%a
    set CONCLUSION=%%b
)

if "%STATUS%"=="in_progress" (
    echo Workflow выполняется, ждём 10 секунд...
    timeout /t 10 >nul
    goto WAIT_COMPLETION
)

echo Workflow завершён со статусом: %CONCLUSION%

REM 4. Скачиваем и выводим лог
gh run view %RUN_ID% --log > build-log.txt
type build-log.txt

pause