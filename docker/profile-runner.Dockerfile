FROM mcr.microsoft.com/playwright:v1.49.0-focal

WORKDIR /usr/src/app

COPY package.json package-lock.json* ./
RUN npm install --only=production || yarn --production

COPY . .

# Ожидается, что контейнер стартует profile-runner скрипт,
# который читает конфиг профиля из ENV/файла и создаёт браузерный контекст.
CMD ["node", "src/backend/profile/profile-runner.js"]

