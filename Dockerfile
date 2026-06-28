# ---------- Stage 1 : Build React App ----------
FROM node:22

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

# ---------- Stage 2 : Serve using Nginx ----------
FROM nginx:alpine

COPY --from=0 /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
