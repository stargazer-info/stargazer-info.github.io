# syntax=docker/dockerfile:1
FROM ruby:alpine

# su-exec をインストール (ユーザー切り替え用)
RUN apk add --no-cache su-exec

# 依存パッケージのインストール
RUN apk update && apk --no-cache upgrade && \
    apk add --no-cache build-base

WORKDIR /app

# Gemfileを先にコピーしてbundle install (キャッシュ効率化)
# Gemfile.lock のコピーを除外します
COPY Gemfile ./
RUN bundle install # Gemfile に基づいて依存関係を解決し、イメージ内に Gemfile.lock を生成します

# entrypoint.sh をコピーして実行権限を付与
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 残りのプロジェクトファイルをコピー
COPY . .

EXPOSE 4000

# entrypoint.sh をコンテナのエントリーポイントとして設定
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# デフォルトで実行するコマンド (entrypoint.sh に引数として渡される)
# docker-compose.yml の command で上書き可能
CMD ["bundle", "exec", "jekyll", "server", "--host=0.0.0.0", "--livereload", "--trace"]
