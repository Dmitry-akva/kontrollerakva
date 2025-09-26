@echo off
REM -----------------------------
REM Скрипт для обновления релиза на GitHub (автоматический коммит)
REM -----------------------------

REM 1. Добавляем все изменения
git add .

REM 2. Коммитим с фиксированным сообщением
git commit -m "Update firmware"

REM 3. Перемещаем локальный тег на новый коммит (замени на свой тег)
set TAG=v1.0.1
git tag -f %TAG%

REM 4. Пушим тег на GitHub с форсом
git push origin -f %TAG%

REM 5. Пушим изменения на main
git push origin main

echo.
echo ===============================
echo Push complete. Workflow should start on GitHub.
echo ===============================
pause