#!/bin/bash

echo "🚀 Локальное тестирование приложения"

# Проверяем наличие Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 не найден"
    exit 1
fi

# Создаем виртуальное окружение если его нет
if [ ! -d "venv" ]; then
    echo "📦 Создаем виртуальное окружение..."
    python3 -m venv venv
fi

# Активируем виртуальное окружение
echo "🔧 Активируем виртуальное окружение..."
source venv/bin/activate

# Устанавливаем зависимости
echo "📥 Устанавливаем зависимости..."
pip install -r backend/requirements.txt

# Создаем директории для данных
echo "📁 Создаем директории..."
mkdir -p data/uploads

# Запускаем приложение
echo "🚀 Запускаем приложение..."
echo "Приложение будет доступно на http://localhost:5000"
echo "Для остановки нажмите Ctrl+C"

export DATA_DIR="./data"
python3 backend/app.py