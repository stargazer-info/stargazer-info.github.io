#!/bin/sh
set -e

# デフォルトのユーザー名、UID、GID
APP_USER_NAME=jekyll
APP_UID_DEFAULT=1000
APP_GID_DEFAULT=1000

# 環境変数からホストのUID/GIDを取得。未設定の場合はデフォルト値を使用。
CURRENT_UID=${HOST_UID:-$APP_UID_DEFAULT}
CURRENT_GID=${HOST_GID:-$APP_GID_DEFAULT}

echo "Starting with UID: $CURRENT_UID, GID: $CURRENT_GID for user $APP_USER_NAME"

# 指定されたGIDのグループが存在しなければ作成
if ! getent group "$CURRENT_GID" >/dev/null 2>&1; then
    echo "Creating group $APP_USER_NAME with GID $CURRENT_GID"
    addgroup -g "$CURRENT_GID" "$APP_USER_NAME"
else
    APP_USER_NAME_FROM_GID=$(getent group "$CURRENT_GID" | cut -d: -f1)
    if [ "$APP_USER_NAME" != "$APP_USER_NAME_FROM_GID" ]; then
        echo "Group GID $CURRENT_GID already exists with name '$APP_USER_NAME_FROM_GID'. Using this name."
        APP_USER_NAME="$APP_USER_NAME_FROM_GID"
    fi
fi

# 指定されたUIDのユーザーが存在しなければ作成
if ! getent passwd "$CURRENT_UID" >/dev/null 2>&1; then
    echo "Creating user $APP_USER_NAME with UID $CURRENT_UID and GID $CURRENT_GID"
    adduser -u "$CURRENT_UID" -G "$APP_USER_NAME" -h "/home/$APP_USER_NAME" -s /bin/sh -D "$APP_USER_NAME"
else
    APP_USER_NAME_FROM_UID=$(getent passwd "$CURRENT_UID" | cut -d: -f1)
    if [ "$APP_USER_NAME" != "$APP_USER_NAME_FROM_UID" ]; then
        echo "User UID $CURRENT_UID already exists with name '$APP_USER_NAME_FROM_UID'. Using this name."
        APP_USER_NAME="$APP_USER_NAME_FROM_UID"
    fi
fi

# .bundle ディレクトリが存在し、かつカレントユーザーが所有していない場合に所有権を変更
if [ -d "/app/.bundle" ] && [ ! -O "/app/.bundle" ]; then
    echo "Changing ownership of /app/.bundle to $CURRENT_UID:$CURRENT_GID"
    chown -R "$CURRENT_UID:$CURRENT_GID" /app/.bundle
fi
if [ -d "/app/vendor/bundle" ] && [ ! -O "/app/vendor/bundle" ]; then
    echo "Changing ownership of /app/vendor/bundle to $CURRENT_UID:$CURRENT_GID"
    chown -R "$CURRENT_UID:$CURRENT_GID" /app/vendor/bundle
fi

echo "Executing command as user '$APP_USER_NAME' (UID: $CURRENT_UID, GID: $CURRENT_GID): $@"
exec su-exec "$APP_USER_NAME" "$@"
