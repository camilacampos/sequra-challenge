FROM ruby:3.2.1-slim as builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install wget -y --no-install-recommends\
    && wget -qO- https://deb.nodesource.com/setup_16.x | bash - \
    && wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

RUN apt-get update \
    && apt-get install -qq -y --no-install-recommends \
    build-essential \
    gpg \
    gpg-agent \
    libpq-dev \
    postgresql-client-13 \
    nodejs \
    yarn \
    git \
    nodejs \
    cmake \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

# ------------------------------------------------------------------------------

RUN mkdir /app
WORKDIR /app

ARG BUNDLE_GITHUB__COM
ENV BUNDLE_GITHUB__COM $BUNDLE_GITHUB__COM

RUN gem install bundler:2.4.5

COPY Gemfile Gemfile.lock /app/

RUN bundle install -j "$(nproc)"
COPY . /app

EXPOSE 7777
ENTRYPOINT ["sh", "init.sh"]
