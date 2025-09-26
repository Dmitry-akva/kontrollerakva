@echo off
REM -----------------------------
REM Автоматический пуш для обновления релиза на GitHub
REM -----------------------------

REM 1. Добавляем все изменения
git add .

REM 2. Коммитим с фиксированным сообщением
git commit -m "Update firmware"

REM 3. Перемещаем локальный тег на последний коммит (замени на свой тег)
set TAG=v1.0.1
git tag -f %TAG%

REM 4. Пушим тег на GitHub с форсом
git push origin -f %TAG%

REM 5. Пушим ветку main с форсом
git push origin main --force

echo.
echo ===============================
echo Push complete. Workflow should start on GitHub.
echo ===============================
pause