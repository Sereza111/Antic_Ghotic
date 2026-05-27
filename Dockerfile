FROM node:20-alpine

WORKDIR /app

# API-only образ (браузер запускается на ПК). Для server-режима см. PROFILE_EXECUTION=server + playwright-образ.
COPY package.json ./
RUN npm install --omit=dev

# исходники
COPY src ./src

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]

