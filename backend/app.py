from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os

app = Flask(__name__)
CORS(app)

# Файл для хранения счётчика
import os
DATA_DIR = os.environ.get('DATA_DIR', '/app/data')
os.makedirs(DATA_DIR, exist_ok=True)
COUNTER_FILE = os.path.join(DATA_DIR, 'counter.json')

def get_counter():
    """Получить текущее значение счётчика"""
    if os.path.exists(COUNTER_FILE):
        try:
            with open(COUNTER_FILE, 'r') as f:
                data = json.load(f)
                return data.get('count', 0)
        except:
            return 0
    return 0

def save_counter(count):
    """Сохранить значение счётчика"""
    with open(COUNTER_FILE, 'w') as f:
        json.dump({'count': count}, f)

@app.route('/api/counter', methods=['GET'])
def get_count():
    """Получить текущее количество кликов"""
    count = get_counter()
    return jsonify({'count': count})

@app.route('/api/counter/increment', methods=['POST'])
def increment_counter():
    """Увеличить счётчик на 1"""
    current_count = get_counter()
    new_count = current_count + 1
    save_counter(new_count)
    return jsonify({'count': new_count})

@app.route('/api/counter/reset', methods=['POST'])
def reset_counter():
    """Сбросить счётчик в 0"""
    save_counter(0)
    return jsonify({'count': 0})

@app.route('/')
def home():
    return jsonify({'message': 'Кликер API работает!', 'endpoints': {
        'GET /api/counter': 'Получить текущий счётчик',
        'POST /api/counter/increment': 'Увеличить счётчик',
        'POST /api/counter/reset': 'Сбросить счётчик'
    }})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True) 