build:
	docker-compose build --build-arg  BUNDLE_GITHUB__COM="${GITHUB_TOKEN}" app

up:
	rm -f tmp/pids/server.pid
	docker network create sequra 2>/dev/null; docker-compose up -d

stop:
	docker-compose stop

restart:
	docker-compose stop && docker-compose up -d

down:
	docker-compose down

run: up
	docker-compose exec app rails db:drop db:setup

run-debugging:
	docker attach $$(docker ps -f name=sequra_challenge-app-1 -q)

rebuild: down build run

test:
	docker-compose exec -e "RAILS_ENV=test" app rspec $(filter-out $@,$(MAKECMDGOALS))

rake:
	docker-compose exec -e "RAILS_ENV=development" app bundle exec rake $(filter-out $@,$(MAKECMDGOALS))

migrate: up
	docker-compose exec app rails db:migrate

rollback: up
	docker-compose exec app rails db:rollback

seed: up
	docker-compose exec -e "RAILS_ENV=development" app rails db:seed

console:
	docker-compose exec app rails console

sh: up
	docker-compose exec app bash

routes:
	docker-compose exec app rails routes

logs:
	docker-compose logs -f app

sidekiq-logs:
	docker-compose logs -f sidekiq

sidekiq-run:
	docker-compose exec app bundle exec sidekiq

lint:
	docker-compose exec app bundle exec standardrb

lint-fix:
	docker-compose exec app bundle exec standardrb --fix

bundle-install:
	docker-compose run --rm app bundle install

bundle-update:
	docker-compose run --rm app bundle update

bundle-add:
	docker-compose run --rm app bundle add $(filter-out $@,$(MAKECMDGOALS))

psql: up
	psql postgres://root@localhost:7771/sequra_challenge_development
