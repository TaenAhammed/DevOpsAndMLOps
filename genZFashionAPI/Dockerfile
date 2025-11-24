FROM node:krypton-alpine
LABEL maintainer="Taen Ahammed"

WORKDIR /app

COPY package*.json .
COPY pnpm-lock.yaml .

RUN npm i

COPY . .

ENV NODE_ENV=production

EXPOSE 3000

CMD ["node", "server.js"]
