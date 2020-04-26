FROM jekyll/jekyll

RUN apk add build-base

RUN apk add --update --no-cache --virtual .build-deps libgcrypt-dev libc-dev libxslt && \
    apk del .build-deps