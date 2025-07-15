#!/bin/bash

# Скрипт для загрузки проекта кликера на VPS сервер
# Запускать с локального компьютера

SERVER_IP="77.222.42.53"
SERVER_USER="root"
SERVER_PASSWORD="TyqXum*tBdg3e4T7"

echo "📤 Загружаем проект кликера на VPS сервер..."

# Проверяем, что мы в правильной папке
if [ ! -f "deploy.sh" ]; then
    echo "❌ Ошибка: Запустите скрипт из папки с проектом (где есть deploy.sh)"
    exit 1
fi

# Создаём архив проекта
echo "📦 Создаём архив проекта..."
tar -czf clicker-project.tar.gz \
    backend/ \
    frontend/ \
    deploy/ \
    deploy.sh \
    README.md \
    upload_to_server.sh

echo "📋 Файлы в архиве:"
tar -tzf clicker-project.tar.gz

# Загружаем на сервер с помощью scp
echo "🚀 Загружаем на сервер $SERVER_IP..."
echo "Введите пароль: $SERVER_PASSWORD"

scp clicker-project.tar.gz root@$SERVER_IP:/tmp/

# Подключаемся к серверу и распаковываем
echo "📂 Распаковываем проект на сервере..."

ssh root@$SERVER_IP << 'EOF'
cd /tmp
tar -xzf clicker-project.tar.gz
chmod +x deploy.sh

echo "✅ Проект загружен в /tmp/"
echo "📍 Теперь запустите: cd /tmp && ./deploy.sh"
EOF

# Удаляем локальный архив
rm clicker-project.tar.gz

echo ""
echo "🎉 Загрузка завершена!"
echo ""
echo "📡 Следующие шаги на сервере:"
echo "   1. ssh root@$SERVER_IP"
echo "   2. cd /tmp"
echo "   3. ./deploy.sh"
echo ""
echo "🌐 После развёртывания сайт будет доступен:"
echo "   http://$SERVER_IP" 