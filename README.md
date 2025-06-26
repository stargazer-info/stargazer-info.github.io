# stargazer-info.github.io
Official Site

# 開発用Docker起動コマンド
## build
docker-compose build --no-cache --build-arg HOST_UID=$(id -u) --build-arg HOST_GID=$(id -g) 
## 起動
docker-compose up
