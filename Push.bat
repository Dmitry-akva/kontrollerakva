@echo off
chcp 65001 >nul
setlocal

echo ===============================
echo 🚀 Auto Push + Update Release
echo ===============================

REM === Настройки ===
set TAG=v1.0.0
set WORKFLOW_NAME=Build ESP8266 Sketch
set WAIT_TIME=15

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

REM === 4. Ждём 30 секунд, чтобы workflow успел стартовать ===
echo ⏳ Ждём 30 секунд, чтобы workflow успел стартовать...
timeout /t 30 >nul

REM === 5. Получаем ID последнего workflow по имени ===
:WAIT_WORKFLOW
set RUN_ID=
for /f "tokens=*" %%i in (
    'gh run list --workflow "%WORKFLOW_NAME%" --limit 1 --json databaseId -q ".[0].databaseId"'
) do set RUN_ID=%%i

if "%RUN_ID%"=="" (
    echo ⏳ Workflow ещё не найден, ждём %WAIT_TIME% секунд...
    timeout /t %WAIT_TIME% >nul
    goto WAIT_WORKFLOW
)

echo ✅ Workflow найден! ID=%RUN_ID%
echo.

REM === 6. Ждём полного завершения workflow ===
:WAIT_COMPLETION
for /f "tokens=*" %%i in (
    'gh run view %RUN_ID% --json status,conclusion -q ".status + \",\" + .conclusion"'
) do set STATUS_CONC=%%i

for /f "tokens=1,2 delims=," %%a in ("%STATUS_CONC%") do (
    set STATUS=%%a
    set CONCLUSION=%%b
)

if "%STATUS%"=="in_progress" (
    echo ⏳ Workflow выполняется, ждём %WAIT_TIME% секунд...
    timeout /t %WAIT_TIME% >nul
    goto WAIT_COMPLETION
)

if "%STATUS%"=="queued" (
    echo ⏳ Workflow ещё в очереди, ждём %WAIT_TIME% секунд...
    timeout /t %WAIT_TIME% >nul
    goto WAIT_COMPLETION
)

echo ✅ Workflow завершён со статусом: %CONCLUSION%
echo.

REM === 7. Сохраняем лог в build-log.txt и выводим сразу в терминал ===
echo ⏬ Выводим лог сборки прямо в терминал:
gh run view %RUN_ID% --log > build-log.txt
type build-log.txt

pause