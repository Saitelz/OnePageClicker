#!/bin/bash

echo "🔧 Исправление проблем с развертыванием..."

# Переходим в директорию проекта
cd /opt/clicker 2>/dev/null || cd .

# Останавливаем все контейнеры
echo "⏹️ Останавливаем контейнеры..."
docker-compose down --remove-orphans

# Проверяем, что порт 80 свободен
echo "🔍 Проверяем занятые порты..."
if netstat -tlnp | grep :80 > /dev/null; then
    echo "⚠️ Порт 80 занят. Проверяем что его занимает:"
    netstat -tlnp | grep :80
    
    # Пытаемся остановить nginx если он запущен
    if systemctl is-active --quiet nginx; then
        echo "🔄 Останавливаем системный nginx..."
        systemctl stop nginx
        systemctl disable nginx
    fi
    
    # Пытаемся остановить apache если он запущен
    if systemctl is-active --quiet apache2; then
        echo "🔄 Останавливаем apache2..."
        systemctl stop apache2
        systemctl disable apache2
    fi
fi

# Очищаем Docker
echo "🧹 Очищаем Docker..."
docker system prune -f
docker volume prune -f

# Пересобираем образы
echo "🔨 Пересобираем образы..."
docker-compose build --no-cache

# Запускаем с новыми портами
echo "🚀 Запускаем контейнеры на портах 8080/8443..."
docker-compose up -d

# Ждем запуска
echo "⏳ Ждем запуска (30 сек)..."
sleep 30

# Проверяем статус
echo "📊 Статус контейнеров:"
docker-compose ps

echo ""
echo "🔍 Проверяем доступность..."

# Проверяем API
if curl -f http://localhost:8080/api/counter &>/dev/null; then
    echo "✅ API работает на порту 8080"
else
    echo "❌ API недоступен"
    echo "📋 Логи бэкенда:"
    docker-compose logs --tail=10 backend
fi

# Проверяем фронтенд
if curl -f http://localhost:8080/ &>/dev/null; then
    echo "✅ Фронтенд работает на порту 8080"
else
    echo "❌ Фронтенд недоступен"
    echo "📋 Логи фронтенда:"
    docker-compose logs --tail=10 frontend
fi

# Проверяем загрузку документов
if curl -f http://localhost:8080/api/documents &>/dev/null; then
    echo "✅ API документов работает"
else
    echo "❌ API документов недоступен"
fi

echo ""
echo "🎉 Исправление завершено!"
echo "📍 Приложение доступно по адресу:"
echo "🌐 http://77.222.42.53:8080"
echo ""
echo "🔧 Если проблемы остались:"
echo "docker-compose logs -f  # Посмотреть логи"
echo "docker-compose restart  # Перезапустить"
echo "docker-compose down && docker-compose up -d  # Полный перезапуск"