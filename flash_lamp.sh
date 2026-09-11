#!/bin/bash
# ============================================
#  AziLamp — Скрипт прошивки лампы (Linux)
# ============================================
# Использование: ./flash_lamp.sh [порт]
# Пример:        ./flash_lamp.sh /dev/ttyUSB0
#                ./flash_lamp.sh (автоопределение)
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKETCH="$SCRIPT_DIR/AziLamp/build/esp8266.esp8266.d1_mini_clone/AziLamp.ino.bin"
WEBFS="$SCRIPT_DIR/AziLamp/build/esp8266.esp8266.d1_mini_clone/mklittlefs.bin"

# Поиск esptool
ESPTOOL=""
if command -v esptool.py &> /dev/null; then
    ESPTOOL="esptool.py"
elif command -v esptool &> /dev/null; then
    ESPTOOL="esptool"
elif [ -f "$HOME/.platformio/packages/tool-esptoolpy/esptool.py" ]; then
    ESPTOOL="python3 $HOME/.platformio/packages/tool-esptoolpy/esptool.py"
else
    echo "❌ esptool не найден!"
    echo "Установите: pip3 install esptool"
    exit 1
fi

# Определение порта
PORT="${1:-}"
if [ -z "$PORT" ]; then
    PORT=$(ls /dev/ttyUSB* 2>/dev/null | head -1)
    if [ -z "$PORT" ]; then
        PORT=$(ls /dev/ttyACM* 2>/dev/null | head -1)
    fi
    if [ -z "$PORT" ]; then
        echo "❌ Плата не найдена! Подключите USB."
        echo "Или укажите порт вручную: ./flash_lamp.sh /dev/ttyUSB0"
        exit 1
    fi
fi

echo "🔌 Порт: $PORT"
echo "🔧 esptool: $ESPTOOL"
echo ""

# Проверка файлов
if [ ! -f "$SKETCH" ]; then
    echo "❌ Не найден скетч: $SKETCH"
    exit 1
fi
if [ ! -f "$WEBFS" ]; then
    echo "⚠️ Не найден веб-интерфейс: $WEBFS"
    echo "Продолжаем без него..."
    WEBFS=""
fi

echo "📦 Прошивка скетча..."
$ESPTOOL --port "$PORT" --baud 115200 --chip esp8266 write_flash \
    --flash_mode qio --flash_freq 40m --flash_size detect \
    0x00000 "$SKETCH"

if [ -n "$WEBFS" ]; then
    echo ""
    echo "🌐 Прошивка веб-интерфейса..."
    $ESPTOOL --port "$PORT" --baud 115200 --chip esp8266 write_flash \
        --flash_mode qio --flash_freq 40m --flash_size detect \
        0x200000 "$WEBFS"
fi

echo ""
echo "✅ Готово! Лампа прошита."
echo "💡 Отключите и подключите питание."
