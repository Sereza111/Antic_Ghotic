## Контракт между профилем и Docker-контейнером

Контейнер `profile-runner` поднимает браузер (Playwright/Puppeteer) под конкретный профиль.

### Входные данные (ENV)

- `PROFILE_ID` — строковый ID профиля.
- `PROFILE_CONFIG_PATH` — путь к JSON-файлу с сериализованным `Profile`.
- `TARGET_URL` — первый URL, который нужно открыть (опционально).
- `AUTOMATION_SCRIPT_ID` — идентификатор сценария, который должен быть выполнен (опционально).

### Конфиг профиля

Файл по `PROFILE_CONFIG_PATH` содержит объект `Profile` из `profile.types.ts`.

Контейнер обязан:

1. Прочитать этот файл при старте.
2. Создать браузерный контекст с учётом:
   - `browserEngine` и `osFamily` (выбор движка/настроек Playwright/Puppeteer).
   - полей `fingerprint.*` — через настроечные слои (evaluateOnNewDocument и т.п.).
3. Если указан `TARGET_URL` — открыть страницу.
4. Если указан `AUTOMATION_SCRIPT_ID` — запросить сценарий у backend по API и выполнить.

### Выходные данные

- Логи выполнения пишутся в STDOUT/STDERR.
- Опционально: артфакты (скриншоты, HTML-снапшоты) сохраняются в каталог `/artifacts/<PROFILE_ID>/<timestamp>/`.

