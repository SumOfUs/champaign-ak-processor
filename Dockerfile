FROM ruby:2.2.2
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy libpq-dev vim postgresql-9.4

RUN mkdir /myapp

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

EXPOSE 3002
ADD . /myapp
WORKDIR /myapp

CMD bundle exec shoryuken -R -C config/shoryuken.yml