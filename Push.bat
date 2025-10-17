@echo off
chcp 65001 >nul
setlocal

echo ===============================
echo 🚀 Auto Push + Update Release
echo ===============================

REM === Настройки ===
set TAG=v1.0.0
set WORKFLOW_NAME=Build ESP8266 Sketch
set WAIT_TIME=20

REM === 1. Добавляем все изменения ===
git add .

REM === 2. Коммит ===
set /p MSG="Введите комментарий коммита: "
if "%MSG%"=="" set MSG=Auto update
git commit -m "%MSG%"

REM === 3. Получаем SHA текущего коммита ===
for /f "tokens=*" %%i in ('git rev-parse HEAD') do set COMMIT_SHA=%%i
echo SHA коммита: %COMMIT_SHA%

REM === 4. Перезаписываем тег на новый коммит ===
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

REM === 5. Ждём workflow, связанный с этим коммитом ===
:WAIT_WORKFLOW
set RUN_ID=
for /f "tokens=*" %%i in (
    'gh run list --workflow "%WORKFLOW_NAME%" --branch main --limit 5 --json databaseId,headSha -q ".[].databaseId | select(.!=null)"'
) do (
    set RUN_ID=%%i
)

if "%RUN_ID%"=="" (
    echo ⏳ Workflow ещё не найден, ждём %WAIT_TIME% секунд...
    timeout /t %WAIT_TIME% >nul
    goto WAIT_WORKFLOW
)

echo ✅ Workflow найден! ID=%RUN_ID%
echo.

REM === 6. Ждём полного завершения workflow ===
:WAIT_COMPLETION
set STATUS=
for /f "tokens=*" %%i in ('gh run view %RUN_ID% --json status -q ".status"') do set STATUS=%%i

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

echo ✅ Workflow завершён.
echo.

REM === 7. Сохраняем лог в build-log.txt и выводим сразу в терминал ===
echo ⏬ Выводим лог сборки прямо в терминал:
gh run view %RUN_ID% --log > build-log.txt
type build-log.txt

pause