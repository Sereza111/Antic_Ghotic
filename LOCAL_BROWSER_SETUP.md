# Браузер на твоём ПК (правильная схема)

- **Сервер** (Portainer): API + MySQL — хранит профили, сценарии, статусы.
- **Твой ПК**: открывает Chromium с изолированным `user-data` для каждого профиля.

## Один раз на Windows

```powershell
cd C:\Users\Yozik\Desktop\Antic
npm install
npx playwright install chromium
```

Нужен **Node.js 20+** в PATH.

## В приложении

1. ⚙ — URL API сервера (например `http://93.189.230.198:3010`).
2. **▶ Старт** на профиле → URL → откроется окно Chromium на этом ПК.
3. Данные профиля лежат в `%LOCALAPPDATA%\Antic\profiles\<id>\`.

Если папка проекта не `C:\Users\Yozik\Desktop\Antic`, задай переменную окружения:

```text
ANTIC_HOME=C:\путь\к\Antic
```

## Portainer

В стеке должно быть (по умолчанию уже так):

```env
PROFILE_EXECUTION=local
```

Не `server` — иначе браузер снова пойдёт в Docker.
