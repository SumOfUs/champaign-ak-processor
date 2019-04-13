FROM soutech/ruby:2.6-alpine-node

ENV APP_ROOT /champaign-ak-processor

RUN mkdir $APP_ROOT
ADD . $APP_ROOT
WORKDIR $APP_ROOT

RUN bundle install --jobs 4 --deployment && bundle package

EXPOSE 3000
CMD bundle exec puma -C config/puma.rb

