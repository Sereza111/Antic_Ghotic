# Деплой backend в Portainer (из GitHub)

Репозиторий: https://github.com/Sereza111/Antic_Ghotic

## Как понять, что на сервере СТАРЫЙ backend

| URL | Старый | Новый |
|-----|--------|-------|
| `/health` | `{"ok":true}` | `{"ok":true,"db":true,"version":"0.2.1"}` |
| `/api/profiles` | 404 Cannot GET | JSON массив |
| Логи контейнера | только `Backend listening on :3000` | `[antic] backend v0.2.1 ...` |

## Обновить образ (обязательно REBUILD)

1. Залей код: `git push origin main`
2. Portainer → **Stacks** → `antic_ghotic`
3. **Editor** → убедись что **Compose path** = `docker-compose.yml` (в корне, не `docker/docker-compose.yml`)
4. **Update the stack** и включи:
   - **Re-pull** (если есть)
   - **Re-build** / пересборка образа (важно!)
5. Если всё равно старый код:
   - **Images** → удали `antic_ghotic-antic-backend` (старый образ)
   - снова **Update the stack**

## Env в стеке

- `MYSQL_HOST` — **IP сервера**, где крутится MySQL (часто тот же `93.189.230.198`).  
  **Нельзя** `127.0.0.1` / `localhost` — из контейнера это «сам контейнер», не твоя БД.
- `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`
- `BACKEND_PORT` — внешний порт (например `3010`)

После старта смотри логи: `[antic] MySQL OK` или `MySQL FAILED`.

## MySQL

Импортируй один раз: `db/antic_full.sql`
