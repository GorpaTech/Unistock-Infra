ROOT_DIR="$(dirname "$(realpath "$0")")/.."

cd $ROOT_DIR

export $(grep -v '^#' .env | grep -v '^$' | xargs)

docker compose up -d

echo "::::: DEPLOY STARTED :::::"
[[ $REPO_GIT ]] && REPO_BRANCH=$REPO_BRANCH || REPO_BRANCH=$ROOT_REPO_BRANCH
(cd src/$PROJECT_DIR && git checkout . && git checkout $REPO_BRANCH && git pull origin $REPO_BRANCH)
docker exec -it $CONTAINER_NAME composer install --no-dev
docker exec -it $CONTAINER_NAME php artisan migrate --force
docker restart $CONTAINER_NAME
docker exec -it $CONTAINER_NAME chown -R nginx:nginx /var/www/app/storage
docker exec -it $CONTAINER_NAME chown -R nginx:nginx /var/www/app/bootstrap/cache
docker exec -it $CONTAINER_NAME yarn
docker exec -it $CONTAINER_NAME yarn build
docker ps
echo "::::: DEPLOY COMPLETED :::::"