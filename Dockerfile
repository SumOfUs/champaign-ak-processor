FROM ruby:2.4.1
RUN apt-get update -qq && apt-get install -y nodejs

ENV APP_ROOT /champaign-ak-processor

RUN mkdir $APP_ROOT
ADD . $APP_ROOT
WORKDIR $APP_ROOT

RUN bundle install --jobs 4 --deployment && bundle package

EXPOSE 3000
CMD bundle exec puma -C config/puma.rb

