#Imagem do laravel
FROM wyveo/nginx-php-fpm:php82

RUN mkdir -p /var/www/app

WORKDIR /var/www/app

#Imagem do vue
FROM node:lts-alpine

RUN npm install -g http-server

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 8080
CMD [ "http-server", "dist" ]