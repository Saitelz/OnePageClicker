# 🎯 Кликер для тестирования VPS сервера

Простое веб-приложение с кнопкой-кликером и счётчиком нажатий для тестирования VPS сервера.

## 🏗️ Архитектура

- **Фронтенд**: Vue.js 3 (одностраничное приложение)
- **Бэкенд**: Python Flask с REST API
- **Веб-сервер**: Nginx (проксирование и статические файлы)
- **Хранение**: JSON файл (простое решение для тестирования)

## 📁 Структура проекта

```
📦 Тест Сервера/
├── 📁 backend/              # Python Flask API
│   ├── app.py              # Основной файл приложения
│   ├── requirements.txt    # Python зависимости
│   └── Dockerfile          # Docker образ для бэкенда
├── 📁 frontend/            # Vue.js приложение
│   ├── index.html         # Одностраничное приложение
│   ├── nginx.conf         # Конфигурация Nginx для Docker
│   └── Dockerfile          # Docker образ для фронтенда
├── 📁 deploy/             # Конфигурации для развёртывания (без Docker)
│   ├── nginx.conf         # Конфигурация Nginx
│   └── start_backend.sh   # Скрипт запуска бэкенда
├── 🐳 docker-compose.yml   # Docker Compose конфигурация
├── 🐳 docker-deploy.sh     # Локальное развёртывание с Docker
├── 🐳 docker-vps-deploy.sh # Развёртывание на VPS с Docker
├── deploy.sh              # Развёртывание без Docker
├── .dockerignore          # Исключения для Docker
└── README.md              # Этот файл
```

## 🐳 Развёртывание с Docker (Рекомендуется)

Docker контейнеры упрощают развёртывание на любом сервере и обеспечивают изоляцию сервисов.

### Локальное тестирование с Docker

```bash
# Клонируйте проект
git clone <ваш-репозиторий>
cd clicker

# Запустите Docker развёртывание
chmod +x docker-deploy.sh
./docker-deploy.sh
```

Кликер будет доступен на http://localhost

### Развёртывание на VPS с Docker

```bash
# 1. Подключитесь к серверу
ssh root@77.222.42.53

# 2. Загрузите проект на сервер
# (скопируйте файлы или используйте git clone)

# 3. Запустите Docker развёртывание
chmod +x docker-vps-deploy.sh
./docker-vps-deploy.sh
```

### Docker команды

```bash
# Статус контейнеров
docker-compose ps

# Логи всех сервисов
docker-compose logs -f

# Логи конкретного сервиса
docker-compose logs -f backend
docker-compose logs -f frontend

# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Полная пересборка
docker-compose down --rmi all --volumes
docker-compose build --no-cache
docker-compose up -d
```

## 🚀 Альтернативное развёртывание (без Docker)

### 1. Подключение к серверу

```bash
ssh root@77.222.42.53
# Пароль: TyqXum*tBdg3e4T7
```

### 2. Загрузка проекта

```bash
# Клонируем или загружаем файлы проекта
git clone <ваш-репозиторий> /tmp/clicker
# ИЛИ скопируйте файлы через scp

cd /tmp/clicker
```

### 3. Автоматическое развёртывание

```bash
# Делаем скрипт исполняемым
chmod +x deploy.sh

# Запускаем развёртывание
./deploy.sh
```

Скрипт автоматически:
- ✅ Обновит систему Ubuntu
- ✅ Установит Python, Nginx и зависимости
- ✅ Настроит файловую структуру
- ✅ Создаст systemd сервис для бэкенда
- ✅ Настроит Nginx для проксирования
- ✅ Настроит firewall
- ✅ Запустит все сервисы

### 4. Проверка результата

После успешного развёртывания сайт будет доступен по адресу:
- **http://77.222.42.53**

## 🔧 Ручная установка (если нужно)

### Установка зависимостей

```bash
# Обновление системы
apt update && apt upgrade -y

# Установка пакетов
apt install -y nginx python3 python3-pip

# Python зависимости
cd backend
pip3 install -r requirements.txt
```

### Запуск бэкенда

```bash
cd backend
python3 app.py
# ИЛИ с gunicorn для продакшена:
gunicorn --bind 0.0.0.0:5000 app:app
```

### Настройка Nginx

```bash
# Копирование конфигурации
cp deploy/nginx.conf /etc/nginx/sites-available/clicker
ln -s /etc/nginx/sites-available/clicker /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Перезапуск
systemctl restart nginx
```

## 🧪 API Endpoints

### Кликер
| Метод | URL | Описание |
|-------|-----|----------|
| `GET` | `/api/counter` | Получить текущий счётчик |
| `POST` | `/api/counter/increment` | Увеличить счётчик на 1 |
| `POST` | `/api/counter/reset` | Сбросить счётчик в 0 |

### Документы
| Метод | URL | Описание |
|-------|-----|----------|
| `GET` | `/api/documents` | Получить список загруженных документов |
| `POST` | `/api/documents/upload` | Загрузить новый документ |
| `GET` | `/api/documents/<id>/view` | Получить URL для просмотра документа |
| `GET` | `/api/documents/<id>/download` | Скачать документ |
| `DELETE` | `/api/documents/<id>` | Удалить документ |

### Примеры запросов

#### Кликер
```bash
# Получить счётчик
curl http://77.222.42.53:5000/api/counter

# Увеличить счётчик
curl -X POST http://77.222.42.53:5000/api/counter/increment

# Сбросить счётчик
curl -X POST http://77.222.42.53:5000/api/counter/reset
```

#### Документы
```bash
# Получить список документов
curl http://77.222.42.53:5000/api/documents

# Загрузить документ
curl -X POST -F "file=@document.docx" http://77.222.42.53:5000/api/documents/upload

# Получить URL для просмотра
curl http://77.222.42.53:5000/api/documents/DOCUMENT_ID/view

# Скачать документ
curl http://77.222.42.53:5000/api/documents/DOCUMENT_ID/download -o document.docx

# Удалить документ
curl -X DELETE http://77.222.42.53:5000/api/documents/DOCUMENT_ID
```

## 🔍 Мониторинг и отладка

### Проверка статуса сервисов

```bash
# Статус бэкенда
systemctl status clicker-backend

# Статус Nginx
systemctl status nginx

# Логи бэкенда
journalctl -u clicker-backend -f

# Логи Nginx
tail -f /var/log/nginx/clicker_error.log
```

### Перезапуск сервисов

```bash
# Перезапуск бэкенда
systemctl restart clicker-backend

# Перезапуск Nginx
systemctl restart nginx
```

## 🎯 Функции приложения

### Кликер
- **💾 Счётчик**: Сохраняется в файл `counter.json`
- **🔄 Сброс**: Возможность сбросить счётчик в 0
- **⚡ Реактивность**: Живые обновления через AJAX
- **📱 Отзывчивость**: Адаптивный дизайн для мобильных
- **🎨 Анимации**: Красивые эффекты при нажатии

### Просмотр документов Office
- **📤 Загрузка файлов**: Поддержка DOC, DOCX, PPT, PPTX, XLS, XLSX, PDF
- **🖱️ Drag & Drop**: Перетаскивание файлов для загрузки
- **👁️ Просмотр**: Модальное окно с просмотром через Google Docs
- **📋 Управление**: Список загруженных документов с возможностью удаления
- **💾 Хранение**: Файлы сохраняются локально на сервере
- **🔒 Безопасность**: Проверка типов файлов и размера (максимум 16MB)

## 🌐 Доступ к ISPManager

Веб-панель управления сервером:
- **URL**: https://77.222.42.53:1500 (или через ISPManager URL)
- **Логин**: root
- **Пароль**: TyqXum*tBdg3e4T7

## 📞 Troubleshooting

### Проблема: Сайт не загружается
```bash
# Проверить nginx
systemctl status nginx
nginx -t

# Проверить права доступа
ls -la /var/www/clicker/
```

### Проблема: API не работает
```bash
# Проверить бэкенд
systemctl status clicker-backend
curl http://localhost:5000/api/counter

# Проверить логи
journalctl -u clicker-backend -n 50
```

### Проблема: CORS ошибки
- Проверьте настройки в `deploy/nginx.conf`
- Убедитесь, что Flask-CORS установлен в бэкенде

---

## 🎯 Тестирование и демо

### Демо интерфейса
Для быстрого просмотра интерфейса откройте файл `demo.html` в браузере:
```bash
open demo.html
```

### Локальное тестирование без Docker
```bash
# Запуск локального сервера для тестирования
chmod +x local-test.sh
./local-test.sh

# Приложение будет доступно на http://localhost:5000
```

### Тестирование с Docker
Прежде чем развёртывать на VPS, протестируйте приложение локально:

```bash
# 1. Убедитесь, что Docker установлен
docker --version
docker-compose --version

# 2. Запустите локальное развёртывание
./docker-deploy.sh

# 3. Откройте в браузере
open http://localhost
```

## 🐳 Быстрый старт с Docker на VPS

```bash
# 1. Подключитесь к серверу
ssh root@77.222.42.53

# 2. Загрузите проект (через git или scp)
git clone <ваш-репозиторий> /tmp/clicker
cd /tmp/clicker

# 3. Запустите автоматическое развёртывание
chmod +x docker-vps-deploy.sh
./docker-vps-deploy.sh

# 4. Готово! Сайт доступен на http://77.222.42.53
```

## 🔧 Управление Docker контейнерами

```bash
# Статус всех контейнеров
docker-compose ps

# Логи в реальном времени
docker-compose logs -f

# Перезапуск сервисов
docker-compose restart

# Остановка
docker-compose down

# Полная пересборка
docker-compose down --rmi all --volumes
docker-compose build --no-cache
docker-compose up -d
```

---

**🎉 Удачного тестирования VPS сервера!** 