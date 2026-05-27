-- Antic demo seed data

INSERT INTO scripts (id, name, description, stepsJson)
VALUES
  (
    's1',
    'Open URL',
    'Демо: открыть страницу',
    JSON_ARRAY(
      JSON_OBJECT('id','st1','type','open_url','url','https://example.com/')
    )
  ),
  (
    's2',
    'Screenshot',
    'Демо: сделать скриншот',
    JSON_ARRAY(
      JSON_OBJECT('id','st1','type','open_url','url','https://example.com/'),
      JSON_OBJECT('id','st2','type','wait','ms',800),
      JSON_OBJECT('id','st3','type','screenshot','fileName','example.png','fullPage',true)
    )
  );

INSERT INTO profiles (id, name, description, browserEngine, osFamily, fingerprintJson, automationJson)
VALUES
  (
    'p1',
    'Готика-1',
    'Демо профиль (server seed)',
    'chromium',
    'windows',
    JSON_OBJECT(
      'canvas', JSON_OBJECT('mode','original'),
      'webgl', JSON_OBJECT('mode','original'),
      'webrtc', JSON_OBJECT('mode','disabled'),
      'fonts', JSON_OBJECT('enabled', false),
      'navigator', JSON_OBJECT('userAgent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'),
      'screen', JSON_OBJECT('width',1280,'height',720),
      'timezone', JSON_OBJECT('tzIanaName','Europe/Moscow')
    ),
    JSON_OBJECT(
      'scriptIds', JSON_ARRAY('s1','s2'),
      'minDelayMs', 500,
      'maxDelayMs', 1500
    )
  );

