@echo off
chcp 65001 >nul
title AziLamp — Прошивка лампы
echo ============================================
echo   🐕 AziLamp — Скрипт прошивки (Windows)
echo ============================================
echo.
echo Использование: flash_lamp.bat COM3
echo.

if "%~1"=="" (
    echo ❌ Укажите порт! Пример: flash_lamp.bat COM3
    echo.
    echo Доступные порты:
    mode | findstr "COM"
    pause
    exit /b 1
)

set PORT=%~1
set SCRIPT_DIR=%~dp0
set SKETCH=%SCRIPT_DIR%AziLamp\build\esp8266.esp8266.d1_mini_clone\AziLamp.ino.bin
set WEBFS=%SCRIPT_DIR%AziLamp\build\esp8266.esp8266.d1_mini_clone\mklittlefs.bin

:: Проверка Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python не установлен!
    echo Скачайте с https://www.python.org/downloads/
    echo ВАЖНО: поставьте галочку "Add Python to PATH"
    pause
    exit /b 1
)

:: Проверка esptool
python -m esptool version >nul 2>&1
if errorlevel 1 (
    echo ⚠️ esptool не установлен. Устанавливаю...
    pip install esptool
)

:: Проверка файлов
if not exist "%SKETCH%" (
    echo ❌ Не найден скетч: %SKETCH%
    pause
    exit /b 1
)

echo 🔌 Порт: %PORT%
echo.

echo 📦 Прошивка скетча...
python -m esptool --port %PORT% --baud 115200 --chip esp8266 write_flash --flash_mode qio --flash_freq 40m --flash_size detect 0x00000 "%SKETCH%"
if errorlevel 1 (
    echo.
    echo ❌ Ошибка прошивки!
    echo Попробуйте ручной BOOT: зажмите FLASH → нажмите RST → отпустите FLASH
    pause
    exit /b 1
)

if exist "%WEBFS%" (
    echo.
    echo 🌐 Прошивка веб-интерфейса...
    python -m esptool --port %PORT% --baud 115200 --chip esp8266 write_flash --flash_mode qio --flash_freq 40m --flash_size detect 0x200000 "%WEBFS%"
) else (
    echo.
    echo ⚠️ Веб-интерфейс не найден, пропускаю.
)

echo.
echo ✅ Готово! Лампа прошита.
echo 💡 Отключите и подключите питание.
pause
