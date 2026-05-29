FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
ENV NODE_ENV=production
WORKDIR /usr/src/app
RUN chown node:node /usr/src/app
USER node
COPY --chown=node:node package*.json ./
RUN npm ci --only=production
COPY --chown=node:node --from=builder /usr/src/app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/index.js"]
