from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from werkzeug.utils import secure_filename
import json
import os
import uuid
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Конфигурация для загрузки файлов
ALLOWED_EXTENSIONS = {'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'pdf'}
MAX_FILE_SIZE = 16 * 1024 * 1024  # 16MB

# Директории для данных
DATA_DIR = os.environ.get('DATA_DIR', '/app/data')
UPLOAD_DIR = os.path.join(DATA_DIR, 'uploads')
os.makedirs(DATA_DIR, exist_ok=True)
os.makedirs(UPLOAD_DIR, exist_ok=True)

COUNTER_FILE = os.path.join(DATA_DIR, 'counter.json')
DOCUMENTS_FILE = os.path.join(DATA_DIR, 'documents.json')

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

def allowed_file(filename):
    """Проверить, разрешен ли тип файла"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_documents():
    """Получить список загруженных документов"""
    if os.path.exists(DOCUMENTS_FILE):
        try:
            with open(DOCUMENTS_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except:
            return []
    return []

def save_documents(documents):
    """Сохранить список документов"""
    with open(DOCUMENTS_FILE, 'w', encoding='utf-8') as f:
        json.dump(documents, f, ensure_ascii=False, indent=2)

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

@app.route('/api/documents', methods=['GET'])
def get_documents_list():
    """Получить список загруженных документов"""
    documents = get_documents()
    return jsonify({'documents': documents})

@app.route('/api/documents/upload', methods=['POST'])
def upload_document():
    """Загрузить документ"""
    if 'file' not in request.files:
        return jsonify({'error': 'Файл не выбран'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Файл не выбран'}), 400
    
    if not allowed_file(file.filename):
        return jsonify({'error': 'Неподдерживаемый тип файла. Разрешены: ' + ', '.join(ALLOWED_EXTENSIONS)}), 400
    
    try:
        # Генерируем уникальное имя файла
        file_id = str(uuid.uuid4())
        original_filename = secure_filename(file.filename)
        file_extension = original_filename.rsplit('.', 1)[1].lower()
        stored_filename = f"{file_id}.{file_extension}"
        
        # Сохраняем файл
        file_path = os.path.join(UPLOAD_DIR, stored_filename)
        file.save(file_path)
        
        # Добавляем информацию о документе
        documents = get_documents()
        document_info = {
            'id': file_id,
            'original_name': original_filename,
            'stored_name': stored_filename,
            'upload_date': datetime.now().isoformat(),
            'size': os.path.getsize(file_path),
            'extension': file_extension
        }
        documents.append(document_info)
        save_documents(documents)
        
        return jsonify({'message': 'Файл успешно загружен', 'document': document_info})
    
    except Exception as e:
        return jsonify({'error': f'Ошибка при загрузке файла: {str(e)}'}), 500

@app.route('/api/documents/<document_id>/download')
def download_document(document_id):
    """Скачать документ"""
    documents = get_documents()
    document = next((doc for doc in documents if doc['id'] == document_id), None)
    
    if not document:
        return jsonify({'error': 'Документ не найден'}), 404
    
    return send_from_directory(UPLOAD_DIR, document['stored_name'], 
                             as_attachment=True, 
                             download_name=document['original_name'])

@app.route('/api/documents/<document_id>/view')
def get_document_view_url(document_id):
    """Получить URL для просмотра документа через Google Docs"""
    documents = get_documents()
    document = next((doc for doc in documents if doc['id'] == document_id), None)
    
    if not document:
        return jsonify({'error': 'Документ не найден'}), 404
    
    # URL для скачивания файла
    download_url = request.url_root + f'api/documents/{document_id}/download'
    
    # URL для просмотра через Google Docs
    google_docs_url = f"https://docs.google.com/gview?url={download_url}&embedded=true"
    
    return jsonify({
        'document': document,
        'view_url': google_docs_url,
        'download_url': download_url
    })

@app.route('/api/documents/<document_id>', methods=['DELETE'])
def delete_document(document_id):
    """Удалить документ"""
    documents = get_documents()
    document = next((doc for doc in documents if doc['id'] == document_id), None)
    
    if not document:
        return jsonify({'error': 'Документ не найден'}), 404
    
    try:
        # Удаляем файл
        file_path = os.path.join(UPLOAD_DIR, document['stored_name'])
        if os.path.exists(file_path):
            os.remove(file_path)
        
        # Удаляем из списка
        documents = [doc for doc in documents if doc['id'] != document_id]
        save_documents(documents)
        
        return jsonify({'message': 'Документ успешно удален'})
    
    except Exception as e:
        return jsonify({'error': f'Ошибка при удалении документа: {str(e)}'}), 500

@app.route('/')
def home():
    return jsonify({'message': 'Кликер API работает!', 'endpoints': {
        'GET /api/counter': 'Получить текущий счётчик',
        'POST /api/counter/increment': 'Увеличить счётчик',
        'POST /api/counter/reset': 'Сбросить счётчик',
        'GET /api/documents': 'Получить список документов',
        'POST /api/documents/upload': 'Загрузить документ',
        'GET /api/documents/<id>/view': 'Получить URL для просмотра',
        'GET /api/documents/<id>/download': 'Скачать документ',
        'DELETE /api/documents/<id>': 'Удалить документ'
    }})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True) 