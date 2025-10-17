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

echo.
echo ===============================
echo ✅ Push complete!
echo Тег %TAG% перезаписан на новый коммит.
echo GitHub Actions соберёт и обновит релиз.
echo ===============================
pause