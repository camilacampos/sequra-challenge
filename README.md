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

> Check out the `Makefile` for more make commands.

## Challenge

### Description

Refer to [challenge_description.md](challenge_description.md)

### Running it
First, you need to migrate the merchants. For that, run:
```bash
make rake create_merchants
```

To create the orders, you first need to import the CSV file into a temp table.

Run `make psql` to get into the database, and then run:
```sql
\copy orders_tmp FROM 'orders.csv' DELIMITER ';' CSV
```

To fill the orders table, run:
```sql
INSERT INTO orders (reference, amount_cents, merchant_id, created_at, updated_at)
SELECT o.id, o.amount::float * 100, m.id, TO_TIMESTAMP(o.created_at, 'YYYY-MM-DD'), CURRENT_TIMESTAMP
FROM orders_tmp o
INNER JOIN merchants m ON m.reference = o.merchant_reference;
```

Next, the commissions need to be calculated for each of the orders. For that, run on your terminal:
```bash
make rake calculate_commissions
```
> :warning: Important: this step will take a very long time to complete.

Lastly, to finish all disbusements calculation, run:
```bash
make rake calculate_disbursements
```

If you want to check a report with disbursements info by year, run:
```bash
make rake generate_report
```

## Report

| Year | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee) |
| --- | --- | --- | --- | --- | --- |
| 2022 | 1548 | 39.173.739,73 € | 350.774,71 € | 1.548 | 212,01 € |
| 2023 | 10352 | 188.363.118,18 € | 1.692.163,42 € | 10.352 | 1.757,16 € |
