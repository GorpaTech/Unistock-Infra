#!/usr/bin/env bash

echo "::::: SETUP STARTED :::::"

echo "Antes de prosseguir realize a configuração das variáveis no arquivo .env.example (da pasta principal)."

read -p "Confirma inicio do setup? ('Ctrl + C' pata cancelar)"

ROOT_DIR="$(dirname "$(realpath "$0")")/.."

cd $ROOT_DIR

cp .env.example .env

export $(grep -v '^#' .env | grep -v '^$' | xargs)
# "source .env" necessário para carregar valores com espaço ex: APP_NAME
source .env

pushd src > /dev/null

git clone $REPO_GIT $PROJECT_DIR

cp $PROJECT_DIR/.env.example $PROJECT_DIR/.env
sed -i "s|@APP_NAME|$APP_NAME|;" $PROJECT_DIR/.env
sed -i "s|@FRONT_URL|$FRONT_URL|;" $PROJECT_DIR/.env
sed -i "s|@DB_HOST|$DB_CONTAINER_NAME|;" $PROJECT_DIR/.env
sed -i "s|@DB_DATABASE|$DB_DATABASE|;" $PROJECT_DIR/.env
sed -i "s|@DB_USER|$DB_USER|;" $PROJECT_DIR/.env
sed -i "s|@DB_PASSWORD|$DB_PASSWORD|;" $PROJECT_DIR/.env
sed -i "s|@FRONT_PORT|$CONTAINER_EXTERNAL_PORT|;" $PROJECT_DIR/.env

popd > /dev/null

cp docker/docker-compose.production.yaml docker-compose.yaml

docker compose build --force-rm --no-cache
docker compose up --force-recreate -d

docker exec -it $CONTAINER_NAME chown -R nginx:nginx /var/www/app/storage
docker exec -it $CONTAINER_NAME chown -R nginx:nginx /var/www/app/bootstrap/cache

# Agora rodar composer install após garantir que as permissões estão corretas
docker exec -it $CONTAINER_NAME composer install
docker exec -it $CONTAINER_NAME php artisan key:generate
docker restart $CONTAINER_NAME
docker exec -it $CONTAINER_NAME php artisan migrate

docker ps

echo "::::: SETUP COMPLETED :::::"