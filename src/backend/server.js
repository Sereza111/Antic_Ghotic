const express = require('express');

const app = express();
app.use(express.json({ limit: '1mb' }));

// Минимальный backend-запускатель. В текущей фазе API не обязателен для docker-demo,
// но нужен как точка входа для дальнейшего расширения (профили/сценарии).
app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

const port = process.env.PORT ? Number(process.env.PORT) : 3000;
app.listen(port, () => {
  console.log(`Backend listening on :${port}`);
});

