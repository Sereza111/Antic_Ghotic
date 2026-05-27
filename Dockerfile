FROM node:20-alpine

WORKDIR /app

# зависимости
COPY package.json ./
RUN npm install --omit=dev

# исходники
COPY src ./src

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]

