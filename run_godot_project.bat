@echo off
REM Запуск, если Godot добавлен в PATH как godot или godot4.
where godot4 >nul 2>nul
if %errorlevel%==0 (
  godot4 --path "%~dp0"
  exit /b
)
where godot >nul 2>nul
if %errorlevel%==0 (
  godot --path "%~dp0"
  exit /b
)
echo Godot не найден в PATH. Открой project.godot вручную через Godot 4.
pause
