#!/usr/bin/env python3
"""
Простой тест для проверки синтаксиса приложения
"""

import sys
import os

# Добавляем путь к бэкенду
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))

try:
    from app import app
    print("✅ Приложение успешно импортировано")
    print("✅ Все зависимости найдены")
    print("✅ Синтаксис корректен")
    
    # Проверяем маршруты
    with app.app_context():
        print("\n📍 Доступные маршруты:")
        for rule in app.url_map.iter_rules():
            print(f"  {rule.methods} {rule.rule}")
            
except ImportError as e:
    print(f"❌ Ошибка импорта: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Ошибка: {e}")
    sys.exit(1)