FROM node:lts-alpine3.18

WORKDIR /contents
ENV LC_ALL=ja_JP.UTF-8

RUN apk update \
 && npm install -g npm \
 && npm init --yes \
 && npm install -g zenn-cli@latest \
 && npm install -g textlint \
 && npm install -g textlint-rule-preset-ja-technical-writing \
 && npm install -g textlint-rule-no-dropping-the-ra \
 && npm install -g textlint-rule-no-mix-dearu-desumasu

ENTRYPOINT ["/usr/local/bin/npx"]