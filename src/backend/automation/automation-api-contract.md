## Automation API (черновой контракт)

API задуман как простой REST JSON, к которому обращается фронтенд.

### Скрипты

- `GET /api/scripts`
  - Возвращает массив `AutomationScript`.

- `GET /api/scripts/:id`
  - Возвращает один `AutomationScript`.

- `POST /api/scripts`
  - Тело: частичный `AutomationScript` без служебных полей (`id`, `createdAt`, `updatedAt` заполняет сервер).
  - Ответ: созданный `AutomationScript`.

- `PUT /api/scripts/:id`
  - Тело: обновлённый `AutomationScript` (или патч-версия).
  - Ответ: актуальный `AutomationScript`.

- `DELETE /api/scripts/:id`
  - Удаление сценария.

### Запуски сценариев

- `POST /api/runs`
  - Тело:
    - `scriptId: string`
    - `profileId: string`
    - `targetUrl?: string`
  - Действия:
    - backend поднимает (или переиспользует) Docker-контейнер профиля;
    - передаёт в контейнер `AUTOMATION_SCRIPT_ID` и `TARGET_URL`;
    - создаёт запись `AutomationRun` со статусом `queued`/`running`.
  - Ответ: `AutomationRun`.

- `GET /api/runs/:id`
  - Возвращает текущее состояние `AutomationRun`.

- `GET /api/runs?profileId=...&scriptId=...`
  - Фильтрация запусков (для истории в UI).

### Фронтенд-использование

- Экран «Сценарии»:
  - список `AutomationScript`;
  - форма/редактор шагов (визуальный конструктор в будущем будет генерить те же `steps`).

- Экран «Профиль»:
  - вкладка `Automation`:
    - выбор одного или нескольких `AutomationScript`;
    - кнопка «Запустить» → `POST /api/runs`.

