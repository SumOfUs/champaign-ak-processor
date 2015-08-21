FROM ruby:2.2.2
RUN apt-get update -qq && apt-get install -y nodejs netcat

RUN mkdir /myapp

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

EXPOSE 3000
ADD . /myapp

CMD bundle exec rails s -b 0.0.0.0