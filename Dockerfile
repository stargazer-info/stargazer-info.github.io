# syntax=docker/dockerfile:1
FROM ruby:alpine

ARG HOST_UID=1000
ARG HOST_GID=1000

RUN if ! getent group $HOST_GID >/dev/null; then \
        addgroup -g $HOST_GID jekyll; \
    fi && \
    adduser -u $HOST_UID -G $(getent group $HOST_GID | cut -d: -f1) -D jekyll && \
    mkdir -p /app && \
    apk update && apk --no-cache upgrade && \
    apk add --no-cache build-base && \
    chown -R jekyll: /app

WORKDIR /app

# COPY --chown=jekyll:jekyll Gemfile ./

# 開発時はボリュームマウントを使用するためコピー不要
COPY --chown=jekyll:jekyll Gemfile ./
COPY --chown=jekyll:jekyll _config.yml .

USER jekyll

RUN bundle install --jobs 4

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "server", "--host=0.0.0.0", "--livereload", "--trace"]
