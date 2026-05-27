/**
 * Локальный запуск профиля на ПК пользователя (Windows).
 * Требуется: Node.js 20+ и один раз в корне проекта: npm install && npx playwright install chromium
 *
 * Запуск вручную:
 *   set PROFILE_ID=p1
 *   set PROFILE_CONFIG_PATH=C:\path\to\profile.json
 *   set TARGET_URL=https://example.com/
 *   set PROFILES_DIR=%LOCALAPPDATA%\Antic\profiles
 *   set HEADLESS=false
 *   node scripts/local-profile-runner.js
 */
process.env.HEADLESS = process.env.HEADLESS || 'false';
process.env.KEEP_ALIVE_SECONDS = process.env.KEEP_ALIVE_SECONDS || '0';

require('../src/backend/profile/profile-runner.js');
