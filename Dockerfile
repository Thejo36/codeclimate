FROM alpine:3.16.0

WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY VERSION /usr/src/app/
COPY codeclimate.gemspec /usr/src/app/
ENV CODECLIMATE_DOCKER=1 BUNDLE_SILENCE_ROOT_WARNING=1

# Add the repository containing the needed ruby and bundler package versions
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" >> /etc/apk/repositories

RUN apk --no-cache upgrade && \
      apk --no-cache --update add \
      build-base \
      ca-certificates \
      git \
      openssh-client \
      openssl \
      ruby=2.7.6-r0 \
      ruby-bigdecimal \
      ruby-bundler \
      ruby-dev \
      wget && \
      bundle install -j 4 && \
      apk del build-base && \
      rm -fr /usr/share/ri

RUN wget -q -O /tmp/docker.tgz \
    https://download.docker.com/linux/static/stable/x86_64/docker-17.12.1-ce.tgz && \
    tar -C /tmp -xzvf /tmp/docker.tgz && \
    mv /tmp/docker/docker /bin/docker && \
    chmod +x /bin/docker && \
    rm -rf /tmp/docker*

COPY . /usr/src/app

VOLUME /code
WORKDIR /code
ENTRYPOINT ["/usr/src/app/bin/codeclimate"]
