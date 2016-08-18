#!/bin/bash

# Some UI helpers

default='\033[0m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;36m'

function message()
{
    trap '' 2
    echo ""
    printf "${1}[${2}]${default}\n"
    echo ""
    trap 2
}

function message_debug()
{
    message ${cyan} "${1}"
}

function message_error()
{
    message ${red} "${1}"
}

function message_info()
{
    message ${yellow} "${1}"
}

function message_success()
{
    message ${green} "${1}"
}

is_ready=0
function mysql_ready() {
    docker exec -it ${db_container} mysql -uroot -proot -e 'SHOW DATABASES' > /dev/null 2> /dev/null
    is_ready=$?
}

# Installing Sylius

if ! [[ -d src ]]; then
    message_info "Clone source code"
    git clone git@github.com:solidusio/solidus.git src
else
    message_info "Pull latest source code"
    cd src
    git pull
    cd ..
fi

# Cleanup previous installs

# Let's get started
docker-compose -f docker-install.yml up -d
ruby_container=$(docker-compose ps -q ruby)

message_info 'Start ruby installation'
message_info 'gem install rails'
docker exec -it ${ruby_container} bash -c 'gem install rails'
message_info 'gem install solidus'
docker exec -it ${ruby_container} bash

exit

docker exec -it ${ruby_container} bash -c 'gem install solidus'
message_info 'ls -lah'
docker exec -it ${ruby_container} bash -c 'ls -lah'
message_info 'gem list | grep rails'
docker exec -it ${ruby_container} bash -c 'gem list | grep rails'
message_info 'bundle exec rails g spree:install'
docker exec -it ${ruby_container} bash -c 'bundle exec rails g spree:install'
# message_info 'bundle exec rails g solidus:auth:install'
# docker exec -it ${ruby_container} bash -c 'bundle exec rails g solidus:auth:install'
# message_info 'bundle exec rake railties:install:migrations'
# docker exec -it ${ruby_container} bash -c 'bundle exec rake railties:install:migrations'
# message_info 'bundle exec rake db:migrate'
# docker exec -it ${ruby_container} bash -c 'bundle exec rake db:migrate'

message_info 'Final touches'

message_info 'Shut down running containers'
docker-compose -f docker-install.yml stop

message_success "Now ready for 'docker-compose start'"

