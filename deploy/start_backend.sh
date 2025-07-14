#!/bin/bash

# Скрипт для запуска Python бэкенда кликера

echo "🚀 Запуск бэкенда кликера..."

# Переходим в папку бэкенда
cd /var/www/clicker/backend

# Проверяем, установлен ли Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 не найден. Устанавливаем..."
    apt update
    apt install -y python3 python3-pip
fi

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
pip3 install -r requirements.txt

# Запускаем приложение с помощью gunicorn
echo "🔥 Запускаем Flask приложение..."
gunicorn --bind 0.0.0.0:5000 --workers 4 --timeout 60 app:app

echo "✅ Бэкенд запущен на порту 5000" 