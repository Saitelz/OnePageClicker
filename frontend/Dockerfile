FROM nginx:alpine

# Копируем файлы фронтенда
COPY index.html /usr/share/nginx/html/
COPY test-api.html /usr/share/nginx/html/

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем порт
EXPOSE 80

# Nginx будет запущен автоматически 