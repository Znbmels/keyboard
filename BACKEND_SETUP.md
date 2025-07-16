# 🚀 Backend API Setup для Muslim AI Keyboard

## 📋 Быстрый старт

### 1. Установка зависимостей

```bash
# Создайте виртуальное окружение
python -m venv venv

# Активируйте его
# На macOS/Linux:
source venv/bin/activate
# На Windows:
venv\Scripts\activate

# Установите зависимости
pip install fastapi uvicorn pillow openai python-multipart aiofiles
```

### 2. Создание основного файла сервера

Создайте файл `main.py`:

```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import time
import uuid
import os
from PIL import Image, ImageDraw, ImageFont
import io
import base64

app = FastAPI(title="Muslim AI Keyboard API", version="1.0.0")

# CORS для iOS приложения
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # В продакшене укажите конкретные домены
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Модели данных
class StickerRequest(BaseModel):
    phrase: str
    username: str = "ios_user"

class Analysis(BaseModel):
    content_type: str
    meaning: str
    emotion: str
    context: str
    recommended_style: str
    recommended_colors: List[str]
    has_user_color_request: bool

class StickerResponse(BaseModel):
    success: bool
    message: str
    image_url: str = None
    content_type: str
    generation_time: float
    analysis: Analysis

class HealthResponse(BaseModel):
    status: str
    agents: dict
    version: str
    islamic_compliance: str

class ExamplesResponse(BaseModel):
    textual_examples: List[str]
    visual_examples: List[str]
    note: str

# Эндпоинты
@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        agents={
            "prompt_agent": "active",
            "image_agent": "active", 
            "save_agent": "active"
        },
        version="1.0.0",
        islamic_compliance="verified"
    )

@app.get("/examples", response_model=ExamplesResponse)
async def get_examples():
    return ExamplesResponse(
        textual_examples=[
            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            "الْحَمْدُ لِلَّهِ",
            "سُبْحَانَ اللَّهِ",
            "اللَّهُ أَكْبَرُ",
            "أَسْتَغْفِرُ اللَّهَ"
        ],
        visual_examples=[
            "мечеть под звездным небом",
            "исламская каллиграфия с золотыми узорами",
            "полумесяц и звезда в зеленых тонах",
            "геометрические исламские орнаменты",
            "минарет на фоне заката"
        ],
        note="Все примеры соответствуют исламским принципам"
    )

@app.post("/generate-sticker", response_model=StickerResponse)
async def generate_sticker(request: StickerRequest):
    start_time = time.time()
    
    try:
        # Анализ фразы
        analysis = analyze_phrase(request.phrase)
        
        # Генерация изображения
        image_data = generate_image(request.phrase, analysis)
        
        # Сохранение изображения (в реальности - в облако)
        image_url = save_image(image_data)
        
        generation_time = time.time() - start_time
        
        return StickerResponse(
            success=True,
            message="Стикер успешно создан",
            image_url=image_url,
            content_type=analysis.content_type,
            generation_time=generation_time,
            analysis=analysis
        )
        
    except Exception as e:
        return StickerResponse(
            success=False,
            message=f"Ошибка генерации: {str(e)}",
            content_type="unknown",
            generation_time=time.time() - start_time,
            analysis=Analysis(
                content_type="error",
                meaning="",
                emotion="",
                context="",
                recommended_style="",
                recommended_colors=[],
                has_user_color_request=False
            )
        )

def analyze_phrase(phrase: str) -> Analysis:
    """Анализ исламской фразы"""
    
    # Определяем тип контента
    arabic_chars = any('\u0600' <= char <= '\u06FF' for char in phrase)
    content_type = "TEXTUAL" if arabic_chars else "VISUAL"
    
    # Анализ значения и эмоций
    islamic_phrases = {
        "بسم الله": ("Во имя Аллаха", "благословение", "начинание"),
        "الحمد لله": ("Хвала Аллаху", "благодарность", "повседневное"),
        "سبحان الله": ("Слава Аллаху", "восхищение", "размышление"),
        "الله أكبر": ("Аллах велик", "возвеличивание", "молитва"),
    }
    
    meaning = "Исламское выражение"
    emotion = "мирный"
    context = "духовный"
    
    for key, (mean, emot, cont) in islamic_phrases.items():
        if key in phrase:
            meaning, emotion, context = mean, emot, cont
            break
    
    return Analysis(
        content_type=content_type,
        meaning=meaning,
        emotion=emotion,
        context=context,
        recommended_style="Элегантная каллиграфия",
        recommended_colors=["изумрудно-зеленый", "золотой", "белый"],
        has_user_color_request=False
    )

def generate_image(phrase: str, analysis: Analysis) -> bytes:
    """Генерация изображения стикера"""
    
    # Создаем изображение 512x512
    img = Image.new('RGB', (512, 512), color='white')
    draw = ImageDraw.Draw(img)
    
    # Градиентный фон
    for y in range(512):
        color_intensity = int(255 * (1 - y / 512))
        color = (0, color_intensity // 2, 0)  # Зеленый градиент
        draw.line([(0, y), (512, y)], fill=color)
    
    # Добавляем текст
    try:
        # Пытаемся использовать системный шрифт
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 40)
    except:
        font = ImageFont.load_default()
    
    # Центрируем текст
    bbox = draw.textbbox((0, 0), phrase, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (512 - text_width) // 2
    y = (512 - text_height) // 2
    
    # Рисуем текст с тенью
    draw.text((x+2, y+2), phrase, font=font, fill='black')  # Тень
    draw.text((x, y), phrase, font=font, fill='white')      # Основной текст
    
    # Добавляем рамку
    draw.rectangle([10, 10, 502, 502], outline='gold', width=4)
    
    # Конвертируем в байты
    img_byte_arr = io.BytesIO()
    img.save(img_byte_arr, format='PNG')
    return img_byte_arr.getvalue()

def save_image(image_data: bytes) -> str:
    """Сохранение изображения и возврат URL"""
    
    # В реальности здесь будет загрузка в облако (AWS S3, etc.)
    # Для демо создаем data URL
    
    base64_image = base64.b64encode(image_data).decode('utf-8')
    return f"data:image/png;base64,{base64_image}"

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 3. Запуск сервера

```bash
# Запустите сервер
python main.py

# Или используя uvicorn напрямую
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 4. Проверка работы

```bash
# Проверьте здоровье API
curl http://localhost:8000/health

# Получите примеры
curl http://localhost:8000/examples

# Сгенерируйте стикер
curl -X POST "http://localhost:8000/generate-sticker" \
     -H "Content-Type: application/json" \
     -d '{"phrase": "بسم الله", "username": "test_user"}'
```

## 🔧 Настройка для iOS

### 1. Локальная разработка

В `APIConfig.swift` убедитесь, что baseURL указывает на ваш локальный сервер:

```swift
static let baseURL = "http://localhost:8000"
```

### 2. Тестирование на устройстве

Если тестируете на реальном устройстве, используйте IP адрес вашего Mac:

```swift
static let baseURL = "http://192.168.1.100:8000"  // Замените на ваш IP
```

Узнать IP адрес: `ifconfig | grep inet`

### 3. Продакшен

Для продакшена разверните сервер на облачной платформе и обновите URL:

```swift
static let baseURL = "https://your-api-server.com"
```

## 🚀 Расширенные возможности

### Интеграция с OpenAI

Добавьте в `main.py`:

```python
import openai

openai.api_key = "your-openai-api-key"

def generate_with_ai(phrase: str) -> str:
    response = openai.Image.create(
        prompt=f"Islamic calligraphy: {phrase}",
        n=1,
        size="512x512"
    )
    return response['data'][0]['url']
```

### Сохранение в облако

```python
import boto3

s3 = boto3.client('s3')

def save_to_s3(image_data: bytes) -> str:
    key = f"stickers/{uuid.uuid4()}.png"
    s3.put_object(
        Bucket='your-bucket',
        Key=key,
        Body=image_data,
        ContentType='image/png'
    )
    return f"https://your-bucket.s3.amazonaws.com/{key}"
```

## 📱 Тестирование с iOS

1. Запустите backend сервер
2. Откройте iOS приложение
3. Перейдите на вкладку "Стикеры"
4. Проверьте индикатор "API Connected" (зеленый)
5. Создайте тестовый стикер

## 🐛 Устранение проблем

### Сервер не запускается
- Проверьте, что порт 8000 свободен: `lsof -i :8000`
- Убедитесь, что все зависимости установлены

### iOS не подключается
- Проверьте firewall на Mac
- Убедитесь, что используете правильный IP адрес
- Проверьте CORS настройки в main.py

### Медленная генерация
- Оптимизируйте размер изображений
- Используйте кэширование
- Добавьте асинхронную обработку

Готово! 🎉 Ваш backend API готов к работе с Muslim AI Keyboard.
