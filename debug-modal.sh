#!/bin/bash

echo "🔍 Отладка проблемы с модальным окном..."

# Проверяем статус контейнеров
echo "📊 Статус контейнеров:"
docker-compose ps

echo ""
echo "🔍 Проверяем API документов:"

# Проверяем основной API
echo "1. Проверка основного API:"
curl -s http://localhost:8080/api/counter | jq . 2>/dev/null || curl -s http://localhost:8080/api/counter

echo ""
echo "2. Проверка API документов:"
curl -s http://localhost:8080/api/documents | jq . 2>/dev/null || curl -s http://localhost:8080/api/documents

echo ""
echo "🔍 Проверяем логи бэкенда:"
docker-compose logs --tail=20 backend

echo ""
echo "🔍 Проверяем логи фронтенда:"
docker-compose logs --tail=10 frontend

echo ""
echo "📋 Инструкции для отладки:"
echo "1. Откройте http://77.222.42.53:8080 в браузере"
echo "2. Откройте Developer Tools (F12)"
echo "3. Перейдите на вкладку Console"
echo "4. Нажмите кнопку 'Тест модального окна'"
echo "5. Проверьте сообщения в консоли"
echo ""
echo "📋 Дополнительные тесты:"
echo "1. Откройте http://77.222.42.53:8080/test-api.html для тестирования API"
echo "2. Загрузите тестовый файл и проверьте его просмотр"
echo ""
echo "🔧 Если проблемы остались:"
echo "docker-compose restart  # Перезапуск"
echo "docker-compose logs -f  # Логи в реальном времени"