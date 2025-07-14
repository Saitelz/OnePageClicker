#!/bin/bash

# Автоматическое развёртывание кликера на VPS сервере
# Для Ubuntu 24.04 LTS

echo "🚀 Начинаем развёртывание кликера на VPS..."

# Обновляем систему
echo "📦 Обновляем систему..."
apt update && apt upgrade -y

# Устанавливаем необходимые пакеты
echo "🔧 Устанавливаем необходимые пакеты..."
apt install -y nginx python3 python3-pip git ufw

# Создаём директорию для проекта
echo "📁 Создаём директории..."
mkdir -p /var/www/clicker/{frontend,backend}

# Копируем файлы проекта (предполагается, что скрипт запускается из папки проекта)
echo "📋 Копируем файлы проекта..."
cp -r frontend/* /var/www/clicker/frontend/
cp -r backend/* /var/www/clicker/backend/
cp -r deploy/ /var/www/clicker/

# Устанавливаем Python зависимости
echo "🐍 Устанавливаем Python зависимости..."
cd /var/www/clicker/backend
pip3 install -r requirements.txt

# Настраиваем nginx
echo "🌐 Настраиваем nginx..."
cp /var/www/clicker/deploy/nginx.conf /etc/nginx/sites-available/clicker
ln -sf /etc/nginx/sites-available/clicker /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверяем конфигурацию nginx
nginx -t

# Настраиваем systemd сервис для Python приложения
echo "⚙️ Создаём systemd сервис..."
cat > /etc/systemd/system/clicker-backend.service << EOF
[Unit]
Description=Clicker Backend Flask App
After=network.target

[Service]
Type=exec
User=www-data
Group=www-data
WorkingDirectory=/var/www/clicker/backend
Environment=PATH=/usr/local/bin:/usr/bin:/bin
ExecStart=/usr/local/bin/gunicorn --bind 127.0.0.1:5000 --workers 4 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Устанавливаем права доступа
echo "🔐 Настраиваем права доступа..."
chown -R www-data:www-data /var/www/clicker
chmod -R 755 /var/www/clicker

# Настраиваем firewall
echo "🔒 Настраиваем firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Запускаем сервисы
echo "🔄 Запускаем сервисы..."
systemctl daemon-reload
systemctl enable clicker-backend
systemctl start clicker-backend
systemctl restart nginx

# Проверяем статус сервисов
echo "✅ Проверяем статус сервисов..."
echo "--- Статус Python бэкенда ---"
systemctl status clicker-backend --no-pager

echo "--- Статус Nginx ---"
systemctl status nginx --no-pager

echo ""
echo "🎉 Развёртывание завершено!"
echo ""
echo "📍 Ваш сайт доступен по адресам:"
echo "   http://77.222.42.53"
echo "   http://77-222-42-53.swtest.ru"
echo ""
echo "🔧 Полезные команды:"
echo "   Перезапуск бэкенда: systemctl restart clicker-backend"
echo "   Перезапуск nginx: systemctl restart nginx"
echo "   Логи бэкенда: journalctl -u clicker-backend -f"
echo "   Логи nginx: tail -f /var/log/nginx/clicker_error.log"
echo ""
echo "🎯 Протестируйте кликер прямо сейчас!" 