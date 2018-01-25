FROM ruby:2.3.3-alpine
LABEL maintainer="David Papp <david@ghostmonitor.com>"

ARG UID=101
ARG GID=101

RUN addgroup -g $GID -S errbit \
  && adduser -u $UID -S -D -s /bin/false -G errbit -g errbit errbit

# throw errors if Gemfile has been modified since Gemfile.lock
RUN echo "gem: --no-document" >> /etc/gemrc \
  && bundle config --global frozen 1 \
  && bundle config --global clean true \
  && bundle config --global disable_shared_gems false

RUN mkdir -p /app \
  && chown -R errbit:errbit /app \
  && chmod 705 /app/
WORKDIR /app

RUN gem update --system 2.7.4 \
  && gem install bundler --version 1.16.1 \
  && apk add --no-cache \
    curl \
    less \
    libxml2-dev \
    libxslt-dev \
    nodejs \
    tzdata \
    git

EXPOSE 8080

COPY ["Gemfile", "Gemfile.lock", "UserGemfile", "/app/"]

COPY netrc /root/.netrc

RUN apk add --no-cache --virtual build-dependencies \
      build-base \
  && bundle config build.nokogiri --use-system-libraries \
  && bundle install \
      -j "$(getconf _NPROCESSORS_ONLN)" \
      --retry 5 \
      --without test development no_docker \
  && apk del build-dependencies

COPY . /app

RUN RAILS_ENV=production bundle exec rake assets:precompile
RUN chown -R errbit:errbit /app

USER errbit

HEALTHCHECK CMD curl --fail "http://$(/sbin/ip route | /usr/bin/awk '/src/{print $NF}'):8080/users/sign_in" ||  exit 1

CMD ["bundle","exec","puma","-C","config/puma.default.rb"]
