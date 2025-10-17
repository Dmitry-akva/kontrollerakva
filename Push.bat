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
set MAX_ATTEMPTS=20
set WAIT_LOG=5
set MAX_ATTEMPTS_LOG=20

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

REM === 4. Получаем дату и SHA последнего коммита ===
for /f "tokens=*" %%i in ('git log -1 --format="%%cI"') do set COMMIT_DATE=%%i
for /f "tokens=*" %%i in ('git rev-parse HEAD') do set COMMIT_SHA=%%i
echo SHA коммита: %COMMIT_SHA%
echo Commit date: %COMMIT_DATE%
echo.

REM === 5. Ждём workflow, связанный с этим коммитом (по дате и времени) ===
set ATTEMPT=0
:WAIT_WORKFLOW
set /a ATTEMPT+=1
set RUN_ID=
for /f "tokens=*" %%i in (
    'gh run list --workflow "%WORKFLOW_NAME%" --created "%COMMIT_DATE%" --limit 5 --json databaseId -q ".[0].databaseId"'
) do set RUN_ID=%%i

if "%RUN_ID%"=="" (
    if %ATTEMPT% GEQ %MAX_ATTEMPTS% (
        echo ❌ Workflow так и не найден по дате и времени. Прерывание.
        pause
        exit /b
    )
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

REM === 7. Скачиваем build-log.txt из релиза и ждём пока он не станет непустым ===
set ATTEMPT_LOG=0
:WAIT_LOG
set /a ATTEMPT_LOG+=1
gh release download %TAG% --pattern "build-log.txt" --dir . >nul 2>&1

if exist build-log.txt (
    for %%i in (build-log.txt) do set FILESIZE=%%~zi
    if %FILESIZE% GTR 0 (
        echo ✅ build-log.txt загружен и не пустой
        goto SHOW_LOG
    )
)

if %ATTEMPT_LOG% GEQ %MAX_ATTEMPTS_LOG (
    echo ❌ build-log.txt не удалось получить после ожидания
    pause
    exit /b
)

echo ⏳ build-log.txt ещё не готов, ждём %WAIT_LOG% секунд...
timeout /t %WAIT_LOG% >nul
goto WAIT_LOG

:SHOW_LOG
echo ⏬ Лог сборки:
type build-log.txt

pause