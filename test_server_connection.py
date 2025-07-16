#!/usr/bin/env python3
"""
Скрипт для тестирования подключения к серверу генерации стикеров
Проверяет доступность всех эндпоинтов API
"""

import requests
import json
import time
from typing import Dict, Any

# Конфигурация сервера
BASE_URL = "https://muslimaikeyboard.tech"
TIMEOUT = 30  # секунд

def test_endpoint(method: str, endpoint: str, data: Dict[Any, Any] = None) -> Dict[str, Any]:
    """Тестирует конкретный эндпоинт"""
    url = f"{BASE_URL}{endpoint}"
    
    print(f"\n🔍 Testing {method} {url}")
    
    try:
        if method == "GET":
            response = requests.get(url, timeout=TIMEOUT)
        elif method == "POST":
            headers = {"Content-Type": "application/json"}
            response = requests.post(url, json=data, headers=headers, timeout=TIMEOUT)
        elif method == "HEAD":
            response = requests.head(url, timeout=TIMEOUT)
        elif method == "OPTIONS":
            response = requests.options(url, timeout=TIMEOUT)
        else:
            return {"success": False, "error": f"Unsupported method: {method}"}
        
        result = {
            "success": True,
            "status_code": response.status_code,
            "headers": dict(response.headers),
            "response_time": response.elapsed.total_seconds()
        }
        
        # Пытаемся получить JSON ответ
        try:
            if response.text:
                result["json"] = response.json()
            else:
                result["json"] = None
        except:
            result["text"] = response.text[:200] if response.text else ""
        
        print(f"✅ Status: {response.status_code}")
        print(f"⏱️ Response time: {response.elapsed.total_seconds():.2f}s")
        
        return result
        
    except requests.exceptions.Timeout:
        print(f"❌ Timeout after {TIMEOUT}s")
        return {"success": False, "error": "Timeout"}
    except requests.exceptions.ConnectionError as e:
        print(f"❌ Connection error: {e}")
        return {"success": False, "error": f"Connection error: {e}"}
    except Exception as e:
        print(f"❌ Error: {e}")
        return {"success": False, "error": str(e)}

def main():
    """Основная функция тестирования"""
    print("🚀 Тестирование сервера генерации стикеров")
    print(f"🌐 Server URL: {BASE_URL}")
    print(f"⏰ Timeout: {TIMEOUT}s")
    print("=" * 50)
    
    # Тест 1: Базовая доступность сервера
    print("\n1️⃣ Тест базовой доступности сервера")
    base_result = test_endpoint("GET", "/")
    
    # Тест 2: Health endpoint
    print("\n2️⃣ Тест /health endpoint")
    health_result = test_endpoint("GET", "/health")
    
    # Тест 3: Test endpoint
    print("\n3️⃣ Тест /test endpoint")
    test_result = test_endpoint("GET", "/test")
    
    # Тест 4: Examples endpoint
    print("\n4️⃣ Тест /examples endpoint")
    examples_result = test_endpoint("GET", "/examples")
    
    # Тест 5: Generate-sticker OPTIONS (CORS)
    print("\n5️⃣ Тест /generate-sticker OPTIONS (CORS)")
    cors_result = test_endpoint("OPTIONS", "/generate-sticker")
    
    # Тест 6: Generate-sticker HEAD
    print("\n6️⃣ Тест /generate-sticker HEAD")
    head_result = test_endpoint("HEAD", "/generate-sticker")
    
    # Тест 7: Generate-sticker POST (реальный запрос)
    print("\n7️⃣ Тест /generate-sticker POST")
    sticker_data = {
        "phrase": "bismillah",
        "username": "test_user"
    }
    sticker_result = test_endpoint("POST", "/generate-sticker", sticker_data)
    
    # Резюме результатов
    print("\n" + "=" * 50)
    print("📊 РЕЗЮМЕ ТЕСТИРОВАНИЯ")
    print("=" * 50)
    
    tests = [
        ("Base URL", base_result),
        ("Health", health_result),
        ("Test", test_result),
        ("Examples", examples_result),
        ("CORS Options", cors_result),
        ("Head Request", head_result),
        ("Sticker Generation", sticker_result)
    ]
    
    successful_tests = 0
    for name, result in tests:
        status = "✅" if result.get("success") else "❌"
        status_code = result.get("status_code", "N/A")
        response_time = result.get("response_time", 0)
        
        print(f"{status} {name:<20} | Status: {status_code} | Time: {response_time:.2f}s")
        
        if result.get("success"):
            successful_tests += 1
        else:
            error = result.get("error", "Unknown error")
            print(f"   Error: {error}")
    
    print(f"\n📈 Успешных тестов: {successful_tests}/{len(tests)}")
    
    # Рекомендации
    print("\n💡 РЕКОМЕНДАЦИИ:")
    
    if successful_tests == 0:
        print("❌ Сервер недоступен. Проверьте:")
        print("   - Запущен ли сервер на http://207.154.222.27")
        print("   - Доступен ли сервер из вашей сети")
        print("   - Не блокирует ли firewall подключения")
    elif successful_tests < len(tests):
        print("⚠️ Некоторые эндпоинты недоступны:")
        for name, result in tests:
            if not result.get("success"):
                print(f"   - {name}: {result.get('error', 'Unknown error')}")
    else:
        print("✅ Все тесты прошли успешно!")
        print("   - Сервер доступен и работает корректно")
        print("   - Можно использовать для генерации стикеров")
    
    # Информация для iOS разработки
    print("\n📱 ДЛЯ iOS РАЗРАБОТКИ:")
    print(f"   - Base URL в APIConfig.swift: \"{BASE_URL}\"")
    print(f"   - Timeout рекомендуется: 120 секунд")
    print(f"   - CORS поддерживается: {'✅' if cors_result.get('success') else '❌'}")

if __name__ == "__main__":
    main()
