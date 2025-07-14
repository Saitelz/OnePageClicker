#!/bin/bash

# Скрипт развёртывания кликера с помощью Docker
# Работает на любой системе с установленным Docker

echo "🐳 Развёртывание кликера с помощью Docker..."

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не найден! Установите Docker:"
    echo "   Ubuntu: sudo apt install docker.io docker-compose"
    echo "   macOS: brew install docker docker-compose"
    echo "   Windows: https://docs.docker.com/desktop/windows/install/"
    exit 1
fi

# Проверяем наличие Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose не найден!"
    exit 1
fi

# Останавливаем существующие контейнеры (если есть)
echo "🔄 Останавливаем существующие контейнеры..."
docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true

# Удаляем старые образы (опционально)
read -p "🗑️  Удалить старые образы? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Удаляем старые образы..."
    docker-compose down --rmi all --volumes --remove-orphans 2>/dev/null || docker compose down --rmi all --volumes --remove-orphans 2>/dev/null || true
fi

# Собираем и запускаем контейнеры
echo "🔨 Собираем Docker образы..."
if command -v docker-compose &> /dev/null; then
    docker-compose build --no-cache
    echo "🚀 Запускаем контейнеры..."
    docker-compose up -d
else
    docker compose build --no-cache
    echo "🚀 Запускаем контейнеры..."
    docker compose up -d
fi

# Ждём запуска сервисов
echo "⏳ Ждём запуска сервисов..."
sleep 10

# Проверяем статус контейнеров
echo "📊 Статус контейнеров:"
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

# Проверяем здоровье сервисов
echo ""
echo "🔍 Проверяем работоспособность..."

# Проверяем бэкенд
if curl -f http://localhost/api/counter &>/dev/null; then
    echo "✅ Бэкенд API работает"
else
    echo "❌ Бэкенд API недоступен"
fi

# Проверяем фронтенд
if curl -f http://localhost/ &>/dev/null; then
    echo "✅ Фронтенд работает"
else
    echo "❌ Фронтенд недоступен"
fi

echo ""
echo "🎉 Развёртывание завершено!"
echo ""
echo "📍 Ваш кликер доступен по адресу:"
echo "   🌐 http://localhost"
echo "   🔧 API: http://localhost/api/counter"
echo ""
echo "🔧 Полезные команды:"
echo "   Логи: docker-compose logs -f"
echo "   Остановка: docker-compose down"
echo "   Перезапуск: docker-compose restart"
echo "   Мониторинг: docker-compose ps"
echo ""
echo "🎯 Протестируйте кликер прямо сейчас!" 