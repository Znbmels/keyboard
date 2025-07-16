# 🔒 App Transport Security (ATS) Setup Instructions

## ❌ Проблема

```
The resource could not be loaded because the App Transport Security policy requires the use of a secure connection.
```

## ✅ Решение

App Transport Security (ATS) в iOS блокирует HTTP соединения по умолчанию, требуя HTTPS. Поскольку ваш сервер работает на HTTP без SSL сертификата, нужно добавить исключение.

## 📝 Что было сделано

### 1. **Создан Info.plist для основного приложения**

Файл: `Keyboard/Info.plist`

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>207.154.222.27</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.0</string>
            <key>NSIncludesSubdomains</key>
            <false/>
        </dict>
    </dict>
</dict>
```

### 2. **Обновлен Info.plist для keyboard extension**

Файл: `KeyboardApp/Info.plist`

Добавлены те же настройки ATS для keyboard extension.

## 🔧 Настройки ATS

### **NSExceptionAllowsInsecureHTTPLoads: true**

- Разрешает HTTP соединения (без HTTPS)
- Необходимо для подключения к `http://207.154.222.27`

### **NSExceptionMinimumTLSVersion: TLSv1.0**

- Минимальная версия TLS (не используется для HTTP)
- Указана для совместимости

### **NSIncludesSubdomains: false**

- Исключение применяется только к указанному домену
- Не распространяется на поддомены

## 🚀 Следующие шаги

### 1. **Добавить Info.plist в проект Xcode**

1. Откройте Xcode
2. Перетащите `Keyboard/Info.plist` в проект
3. Убедитесь, что он добавлен к основному target'у

### 2. **Проверить настройки Build Settings**

1. Выберите основной target в Xcode
2. Перейдите в Build Settings
3. Найдите "Info.plist File"
4. Убедитесь, что путь указывает на `Keyboard/Info.plist`

### 3. **Протестировать подключение**

1. Запустите приложение
2. Нажмите "Test Server Connection"
3. Попробуйте сгенерировать стикер

## ⚠️ Важные замечания

### **Безопасность**

- ATS исключения снижают безопасность
- Используйте только для доверенных серверов
- В продакшене рекомендуется HTTPS

### **App Store Review**

- Apple может запросить объяснение ATS исключений
- Подготовьте обоснование использования HTTP API

### **Альтернативы**

1. **SSL сертификат**: Добавьте HTTPS на сервер
2. **Прокси**: Используйте HTTPS прокси для HTTP API
3. **Локальный сервер**: Для разработки

## 🧪 Тестирование

### **Проверка ATS настроек**

```bash
# Проверить доступность сервера
curl -v https://muslimaikeyboard.tech/test

# Тест генерации стикера
curl -X POST https://muslimaikeyboard.tech/generate-sticker \
  -H "Content-Type: application/json" \
  -d '{"phrase": "bismillah", "username": "test"}'
```

### **В iOS приложении**

1. Запустите приложение в симуляторе
2. Перейдите в раздел генерации стикеров
3. Нажмите "Test Server Connection"
4. Результат должен быть: ✅ Server accessible

## 📱 Для разных сред

### **Development (Разработка)**

```xml
<key>207.154.222.27</key>
<dict>
    <key>NSExceptionAllowsInsecureHTTPLoads</key>
    <true/>
</dict>
```

### **Production (Продакшен)**

Рекомендуется использовать HTTPS:

```xml
<!-- Удалить ATS исключения и использовать HTTPS -->
<key>NSAppTransportSecurity</key>
<dict>
    <!-- Стандартные настройки ATS -->
</dict>
```

## 🔍 Отладка

### **Если ATS все еще блокирует:**

1. Проверьте, что Info.plist добавлен в проект
2. Убедитесь, что домен указан правильно
3. Перезапустите приложение
4. Проверьте консоль Xcode на ошибки ATS

### **Логи ATS в консоли:**

```
ATS failed system trust
NSURLSession/NSURLConnection HTTP load failed
```

## ✅ Готово!

После выполнения этих шагов ваше приложение сможет подключаться к HTTP серверу `http://207.154.222.27` и генерировать стикеры! 🎉
