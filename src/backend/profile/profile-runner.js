const fs = require('fs');
const path = require('path');

const { chromium, firefox, webkit } = require('playwright');

function readJson(filePath) {
  const p = path.resolve(filePath);
  const raw = fs.readFileSync(p, 'utf8');
  return JSON.parse(raw);
}

function pickEngine(browserEngine) {
  switch (browserEngine) {
    case 'firefox':
      return firefox;
    case 'webkit':
      return webkit;
    case 'chromium':
    default:
      return chromium;
  }
}

function clamp(n, min, max) {
  if (typeof n !== 'number' || Number.isNaN(n)) return undefined;
  return Math.max(min, Math.min(max, n));
}

async function main() {
  const profileId = process.env.PROFILE_ID || 'demo';
  const profileConfigPath = process.env.PROFILE_CONFIG_PATH;
  const targetUrl = process.env.TARGET_URL || 'https://example.com/';
  const keepAliveSeconds = Number(process.env.KEEP_ALIVE_SECONDS || 0);

  if (!profileConfigPath) {
    console.error('Missing env: PROFILE_CONFIG_PATH');
    process.exit(2);
  }

  const profile = readJson(profileConfigPath);

  // Изоляция “профиля”: отдельный persistent user-data directory на PROFILE_ID.
  // Это не “взламывает” сайты, а даёт воспроизводимые условия для тестирования/QA.
  const userDataDir = path.resolve(process.env.PROFILES_DIR || '/profiles', profileId);
  fs.mkdirSync(userDataDir, { recursive: true });

  const Engine = pickEngine(profile.browserEngine);

  const fp = profile.fingerprint || {};
  const navigator = fp.navigator || {};
  const screen = fp.screen || {};
  const timezone = fp.timezone || {};

  const launchOptions = {
    headless: true,
    userAgent: navigator.userAgent || undefined,
    // locale/timezoneId настраиваются отдельно, т.к. зависят от доступных полей профиля.
    locale: undefined,
  };

  // viewport: используем только базовые параметры (без антифрод/антидетект байпасов).
  const viewport = {
    width: clamp(screen.width, 320, 5000) || 1280,
    height: clamp(screen.height, 240, 5000) || 720,
  };

  const context = await Engine.launchPersistentContext(userDataDir, {
    ...launchOptions,
    viewport,
    timezoneId: typeof timezone.tzIanaName === 'string' ? timezone.tzIanaName : undefined,
  });

  const page = await context.newPage();
  page.setDefaultTimeout(30000);

  await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1000);

  const artifactsDir = path.resolve(process.env.ARTIFACTS_DIR || '/artifacts', profileId);
  fs.mkdirSync(artifactsDir, { recursive: true });
  const fileName = `page-${Date.now()}.png`;
  await page.screenshot({ path: path.join(artifactsDir, fileName), fullPage: true });

  console.log(JSON.stringify({ type: 'result', profileId, url: targetUrl, screenshot: fileName }));

  if (keepAliveSeconds > 0) {
    console.log(`Keep alive for ${keepAliveSeconds}s...`);
    await new Promise((r) => setTimeout(r, keepAliveSeconds * 1000));
  }

  await context.close();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

