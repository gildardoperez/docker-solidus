FROM ruby:onbuild

WORKDIR /src

ADD Gemfile /src/Gemfile
ADD Gemfile.lock /src/Gemfile.lock

RUN set -x \
	&& apt-get update -qq && apt-get install -y build-essential \
	&& bundle install

EXPOSE 3000

