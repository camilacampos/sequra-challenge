#!/bin/sh

set -e

COMMAND="$1"

case "$COMMAND" in
  web)
    exec bundle exec rails s -p 7777 -b '0.0.0.0'
    ;;
  migrate)
    exec bundle exec rails db:migrate
    ;;
  sidekiq)
    exec bundle exec sidekiq
    ;;
  test)
    exec bundle exec rspec ./spec
    ;;
  *)
    exec sh -c "$@"
    ;;
esac
