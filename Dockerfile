FROM ruby:3.2-slim

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=enabled
ENV LANG=en_US.UTF-8
ENV RACK_ENV=production
ENV RAILS_LOG_TO_STDOUT=enabled
ENV SECRET_KEY_BASE="1234567890"
ENV RECAPTCHA_SITE_KEY="1234567890"
ENV RECAPTCHA_SECRET_KEY="1234567890"
ENV MONGODB_URI="mongodb://legacy:password@localhost/legacy"

WORKDIR /usr/src

COPY Gemfile Gemfile.lock /usr/src/

RUN apt update \
  && apt install -y nodejs build-essential \
  && bundle config set --local without 'development test' \
  && bundle install \
  && apt purge -y --auto-remove build-essential \
  && rm -rf /var/lib/apt/lists/*

COPY . /usr/src/

RUN rake app:update:bin && rake assets:precompile && rake assets:clean && rake tmp:create

EXPOSE 3000

ENTRYPOINT [ "./bin/rails" ]
CMD ["s", "-p", "3000", "-b", "0.0.0.0", "-e", "${RAILS_ENV}"]