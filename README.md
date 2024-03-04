# SeQura Backend Coding Challenge

## Setup
### System requirements

| Dependency     | Version     |
| -------------- | ----------- |
| PostgreSQL     | **13.x**    |
| Docker         | **24.0.6**  |
| Docker-compose | **2.22.0**  |

### Running the application

To build the system, run: `make build`

Make sure the network sequra is created: `docker network create sequra`

To install and/or update dependencies, run: `make bundle-install`

To run the application, run: `make run`

To run a terminal attached with debug active (pry), run: `make run-debugging`

### Testing and linting

**Tests**
```bash
make test # run all tests
make test spec/path_to_spec.rb # run tests of an specific file
make test spec/path_to_spec.rb:34 # run test at an specific line of a file

make test-failures # run only previously failed tests
```

**Lint**
```bash
make lint # run lint
make lint-fix # run lint and automatically fix issues
```

## Challenge description

Refer to [challenge_description.md](challenge_description.md)

## Report

| Year | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee) |
| --- | --- | --- | --- | --- | --- |
| 2022 | 1548 | 39.173.739,73 € | 350.774,71 € | 1.548 | 212,01 € |
| 2023 | 10352 | 188.363.118,18 € | 1.692.163,42 € | 10.352 | 1.757,16 € |

