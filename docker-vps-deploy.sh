#!/bin/bash

# Скрипт для развёртывания кликера на VPS с помощью Docker
# Для Ubuntu 24.04 LTS

echo "🐳 Развёртывание кликера на VPS с Docker..."

# Проверяем, что мы на Ubuntu
if [ ! -f /etc/os-release ] || ! grep -q "Ubuntu" /etc/os-release; then
    echo "⚠️  Этот скрипт предназначен для Ubuntu. Продолжить? (y/N)"
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Обновляем систему
echo "📦 Обновляем систему..."
apt update && apt upgrade -y

# Устанавливаем Docker, если не установлен
if ! command -v docker &> /dev/null; then
    echo "🐳 Устанавливаем Docker..."
    
    # Удаляем старые версии
    apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Устанавливаем зависимости
    apt install -y ca-certificates curl gnupg lsb-release
    
    # Добавляем GPG ключ Docker
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Добавляем репозиторий Docker
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Устанавливаем Docker
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Запускаем Docker
    systemctl start docker
    systemctl enable docker
    
    echo "✅ Docker установлен"
else
    echo "✅ Docker уже установлен"
fi

# Устанавливаем Docker Compose, если не установлен
if ! command -v docker-compose &> /dev/null; then
    echo "🔧 Устанавливаем Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose установлен"
else
    echo "✅ Docker Compose уже установлен"
fi

# Создаём директорию для проекта
PROJECT_DIR="/opt/clicker"
echo "📁 Создаём директорию проекта: $PROJECT_DIR"
mkdir -p $PROJECT_DIR

# Копируем файлы проекта в PROJECT_DIR
if [ -f "docker-compose.yml" ]; then
    echo "📋 Копируем файлы проекта..."
    cp -r * $PROJECT_DIR/ 2>/dev/null || true
    cd $PROJECT_DIR
else
    echo "❌ Файл docker-compose.yml не найден. Убедитесь, что запускаете скрипт из папки проекта."
    exit 1
fi

# Устанавливаем права доступа
chown -R root:root $PROJECT_DIR
chmod +x $PROJECT_DIR/docker-deploy.sh 2>/dev/null || true

# Настраиваем firewall
echo "🔒 Настраиваем firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
fi

# Останавливаем существующие контейнеры
echo "🔄 Останавливаем существующие контейнеры..."
docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true

# Собираем и запускаем контейнеры
echo "🔨 Собираем Docker образы..."
docker-compose build --no-cache || docker compose build --no-cache

echo "🚀 Запускаем контейнеры..."
docker-compose up -d || docker compose up -d

# Создаём systemd сервис для автозапуска
echo "⚙️ Создаём systemd сервис..."
cat > /etc/systemd/system/clicker-docker.service << EOF
[Unit]
Description=Clicker Docker Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Включаем автозапуск
systemctl daemon-reload
systemctl enable clicker-docker

# Ждём запуска сервисов
echo "⏳ Ждём запуска сервисов..."
sleep 15

# Проверяем статус
echo "📊 Статус контейнеров:"
docker-compose ps || docker compose ps

# Проверяем доступность
echo ""
echo "🔍 Проверяем работоспособность..."

# Получаем IP сервера
SERVER_IP=$(curl -s http://checkip.amazonaws.com/ || curl -s http://ipinfo.io/ip)

if curl -f http://localhost/api/counter &>/dev/null; then
    echo "✅ API работает"
else
    echo "❌ API недоступен"
fi

if curl -f http://localhost/ &>/dev/null; then
    echo "✅ Фронтенд работает"
else
    echo "❌ Фронтенд недоступен"
fi

echo ""
echo "🎉 Развёртывание завершено!"
echo ""
echo "📍 Ваш кликер доступен по адресам:"
if [ ! -z "$SERVER_IP" ]; then
    echo "   🌐 http://$SERVER_IP"
fi
echo "   🌐 http://77.222.42.53"
echo "   🌐 http://77-222-42-53.swtest.ru"
echo ""
echo "🔧 Полезные команды:"
echo "   Логи: cd $PROJECT_DIR && docker-compose logs -f"
echo "   Статус: cd $PROJECT_DIR && docker-compose ps"
echo "   Перезапуск: systemctl restart clicker-docker"
echo "   Остановка: cd $PROJECT_DIR && docker-compose down"
echo ""
echo "🎯 Протестируйте кликер прямо сейчас!" 