#!/bin/bash

echo "🔄 Перезапуск Docker контейнеров с исправлениями..."

# Останавливаем текущие контейнеры
echo "⏹️ Останавливаем контейнеры..."
docker-compose down

# Удаляем старые образы для пересборки
echo "🗑️ Очищаем старые образы..."
docker-compose down --rmi all --volumes --remove-orphans

# Пересобираем и запускаем
echo "🔨 Пересобираем образы..."
docker-compose build --no-cache

echo "🚀 Запускаем контейнеры..."
docker-compose up -d

# Ждем запуска
echo "⏳ Ждем запуска сервисов..."
sleep 10

# Проверяем статус
echo "📊 Статус контейнеров:"
docker-compose ps

# Проверяем логи
echo "📋 Последние логи:"
docker-compose logs --tail=20

echo ""
echo "🎉 Перезапуск завершен!"
echo "📍 Приложение доступно по адресу:"
echo "🌐 http://77.222.42.53:8080"
echo ""
echo "🔧 Полезные команды:"
echo "Логи: docker-compose logs -f"
echo "Статус: docker-compose ps"
echo "Остановка: docker-compose down"