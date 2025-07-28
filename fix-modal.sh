#!/bin/bash

echo "🔧 Исправление модального окна..."

# Останавливаем контейнеры
echo "⏹️ Останавливаем контейнеры..."
docker-compose down

# Пересобираем только фронтенд
echo "🔨 Пересобираем фронтенд..."
docker-compose build --no-cache frontend

# Запускаем контейнеры
echo "🚀 Запускаем контейнеры..."
docker-compose up -d

# Ждем запуска
echo "⏳ Ждем запуска (20 сек)..."
sleep 20

# Проверяем статус
echo "📊 Статус контейнеров:"
docker-compose ps

echo ""
echo "🎯 Тестирование исправлений:"
echo "1. Откройте http://77.222.42.53:8080"
echo "2. Откройте Developer Tools (F12) -> Console"
echo "3. Нажмите 'Тест модального окна'"
echo ""
echo "🔍 Что должно произойти:"
echo "- Модальное окно должно появиться с красной рамкой (отладка)"
echo "- В консоли должны появиться сообщения о модальном элементе"
echo "- Если модальное окно не появляется, выполните в консоли:"
echo "  document.querySelector('.modal').style.display = 'flex'"
echo ""
echo "🔧 Дополнительная отладка:"
echo "В консоли браузера выполните:"
echo "console.log('Modal element:', document.querySelector('.modal'));"
echo "console.log('showModal value:', app.showModal);"