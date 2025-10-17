@echo off
chcp 65001 >nul
setlocal

echo ===============================
echo 🚀 Auto Push + Update Release
echo ===============================

REM === Настройки ===
set TAG=v1.0.0

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

REM === 4. Удаляем старые артефакты релиза ===
for /f "tokens=*" %%i in ('gh release view %TAG% --json id -q ".id" 2^>nul') do set RELEASE_ID=%%i
if defined RELEASE_ID (
    echo ❌ Релиз %TAG% найден. Удаляем все артефакты...
    for /f "tokens=*" %%a in ('gh release view %TAG% --json assets -q ".assets[].name"') do (
        echo Удаляем %%a
        gh release delete-asset %%a --release %RELEASE_ID% --confirm
    )
)

REM === 5. Цикл скачивания build-log.txt до тех пор, пока файл не будет не пустой ===
:DOWNLOAD_LOG
echo ⏬ Скачиваем build-log.txt из релиза %TAG%...
gh release download %TAG% --pattern "build-log.txt" --dir . --force

if not exist build-log.txt (
    echo ⚠️ Файл build-log.txt не найден. Пробуем снова через 10 секунд...
    timeout /t 10 >nul
    goto DOWNLOAD_LOG
)

for %%i in (build-log.txt) do if %%~zi==0 (
    echo ⚠️ Файл пустой. Пробуем снова через 10 секунд...
    timeout /t 10 >nul
    goto DOWNLOAD_LOG
)

REM === 6. Выводим лог в терминал ===
type build-log.txt

echo.
echo ===============================
echo ✅ Всё готово!
echo ===============================
pause