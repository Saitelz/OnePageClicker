#!/bin/bash

echo "🔄 Обновление приложения с отладкой модального окна..."

# Останавливаем контейнеры
echo "⏹️ Останавливаем контейнеры..."
docker-compose down

# Пересобираем образы
echo "🔨 Пересобираем образы с отладкой..."
docker-compose build --no-cache

# Запускаем контейнеры
echo "🚀 Запускаем контейнеры..."
docker-compose up -d

# Ждем запуска
echo "⏳ Ждем запуска (30 сек)..."
sleep 30

# Проверяем статус
echo "📊 Статус контейнеров:"
docker-compose ps

echo ""
echo "🔍 Проверяем API:"

# Проверяем основной API
echo "1. Основной API:"
curl -s http://localhost:8080/api/counter

echo ""
echo "2. API документов:"
curl -s http://localhost:8080/api/documents

echo ""
echo "🎯 Тестирование:"
echo "1. Основное приложение: http://77.222.42.53:8080"
echo "2. Тест API: http://77.222.42.53:8080/test-api.html"
echo ""
echo "🔍 Отладка модального окна:"
echo "1. Откройте http://77.222.42.53:8080"
echo "2. Откройте Developer Tools (F12) -> Console"
echo "3. Нажмите 'Тест модального окна'"
echo "4. Проверьте сообщения в консоли"
echo ""
echo "📋 Ожидаемое поведение:"
echo "- При нажатии 'Тест модального окна' должно появиться модальное окно"
echo "- В консоли должны появиться сообщения отладки"
echo "- Модальное окно должно показать тестовый PDF"
echo ""
echo "🔧 Если проблемы остались:"
echo "docker-compose logs -f backend  # Логи бэкенда"
echo "docker-compose logs -f frontend # Логи фронтенда"