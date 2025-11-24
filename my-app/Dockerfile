# Stage 1: Build
FROM node:krypton-alpine AS builder
LABEL maintainer="Taen Ahammed"
WORKDIR /app

COPY package*.json .
RUN npm i

COPY . .

RUN npm run build

# Stage 2: Production (nginx)
# Lightweight base/distroless base image + only prod deps 
FROM node:krypton-alpine AS runner
WORKDIR /app
RUN npm i -g serve

COPY --from=builder /app/dist ./dist
EXPOSE 4000

CMD ["serve", "-s", "dist", "-l", "4000"]