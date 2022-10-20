FROM ruby:2.7.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /z
WORKDIR /z
ADD Gemfile /z/Gemfile
ADD Gemfile.lock /z/Gemfile.lock
RUN bundle install
ADD . /z