FROM ruby:2.3.0
RUN apt-get update -qq && apt-get install -y nodejs netcat

RUN mkdir /myapp

WORKDIR /myapp

ADD Gemfile /myapp/
ADD Gemfile.lock /myapp/
ADD . /myapp
RUN bundle install --system --jobs 4

EXPOSE 3000

CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 1:16

