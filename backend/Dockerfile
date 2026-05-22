FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3000

ENV NODE_OPTIONS="--dns-result-order=ipv4first"

CMD ["node", "dist/main.js"]
