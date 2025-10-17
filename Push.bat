@echo off
chcp 65001 >nul
echo ===============================
echo Auto Push + Tag for GitHub Build
echo ===============================
REM 1. Добавляем все изменения
git add .

REM 2. Коммитим с сообщением
set /p MSG="Введите комментарий коммита: "
if "%MSG%"=="" set MSG=Auto build
git commit -m "%MSG%"

REM 3. Определяем последний тег и увеличиваем версию
for /f "tokens=2 delims=v" %%a in ('git describe --tags --abbrev^=0 2^>nul') do set LAST=%%a
if "%LAST%"=="" (set LAST=0.0.0)

for /f "tokens=1-3 delims=." %%a in ("%LAST%") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

set /a PATCH=%PATCH%+1
set TAG=v%MAJOR%.%MINOR%.%PATCH%

echo 🏷 Новый тег: %TAG%

REM 4. Создаём и пушим новый тег
git tag -a %TAG% -m "%MSG%"
git push origin main
git push origin %TAG%

echo.
echo ===============================
echo ✅ Push complete.
echo Новый тег %TAG% отправлен на GitHub.
echo GitHub Actions теперь сам соберёт прошивку.
echo ===============================
pause