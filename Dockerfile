# syntax=docker/dockerfile:1
FROM ruby:alpine

ARG HOST_UID=1000
ARG HOST_GID=1000

RUN if ! getent group $HOST_GID >/dev/null; then \
        addgroup -g $HOST_GID jekyll; \
    fi && \
    adduser -u $HOST_UID -G $(getent group $HOST_GID | cut -d: -f1) -D jekyll && \
    mkdir -p /app && \
    chown -R jekyll:jekyll /app && \
    apk add --no-cache build-base

WORKDIR /app

COPY --chown=jekyll:jekyll Gemfile ./
RUN bundle install --jobs 4

COPY --chown=jekyll:jekyll _posts/ ./_posts/
COPY --chown=jekyll:jekyll _drafts/ ./_drafts/
COPY --chown=jekyll:jekyll _includes/ ./_includes/
COPY --chown=jekyll:jekyll assets/ ./assets/
COPY --chown=jekyll:jekyll _config.yml .

EXPOSE 4000

USER jekyll

CMD ["bundle", "exec", "jekyll", "server", "--host=0.0.0.0", "--livereload", "--trace"]
