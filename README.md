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

## Decision making and thought process

### Models and relationships

The models follow the following structure:
<img width="1256" alt="image" src="https://github.com/camilacampos/sequra-challenge/assets/2309096/4a82a5b6-d192-4fb9-ad6f-5e50efb9f076">

* Merchant: company that sells any goods with SeQura
* Order: orders that a merchant make through SeQura
* Commission: Fee that SeQura get for each order
* Disbursement: Group of orders to be paid on the same day or week for a merchant

_PS. The attributes of each model are explained in the model files_

### Architecture

I decided to use use cases to do all of the operations, even the simpler ones, so that the code stays modularized and everything is easy to reuse, change, maintain and test. (They can be all found in the `/app/use_cases` folder.)

On those use cases, I went for a "step by step" approach, where a step could be implemented as a method in the current use case or as another use case for when the step were more complex. My idea here was also make something ready for an event based approach, where use cases emit events and other use cases react to them.

### Solution

To calculate the commission values for the disbursements, one possibility was to run a process everyday going through all the orders that need to be disbursed that day and calculating its commission and disbursement. However, this could lead to a very slow process.

To avoid that, I decide to have a more event-oriented approach, where whenever a new order comes, its commission values are already calculated and saved.

<img width="607" alt="image" src="https://github.com/camilacampos/sequra-challenge/assets/2309096/cd94efd7-804e-4135-b0ac-091cb2765c83">

This approach showed itself not very great when migrating all orders data, because de CSV is too large and the process was taking too long to run. I tried to optimize the code by making less queries along the process, but it was not very effective.

To mitigate this problem, I changed the migration approach to use a tmp table with orders data loaded from the CSV and a INSERT command to fill the orders table correctly. That led to inconsistent data (orders without commissions), that was fixed by a rake task responsible for calculating and creating the commissions for all of the orders. At this point, making the code very modular was really helpful because I could just call the use case that was already doing what I needed. Anyways, it took about 3 hours for the rake to run.

To actually "close" a disbursement, a daily process (using a Sidekiq cron job) will run through both daily and weekly disbursements that need to be finished that day and change their status, without needing any new calculations for that, and calculate the monthly fee if necessary.

Since we need to test all of the disbursements calculated, I also added a rake task that calculates all disbursements.

<img width="786" alt="image" src="https://github.com/camilacampos/sequra-challenge/assets/2309096/6d87df2e-b1e3-4acd-93a1-a2285fc9f5ae">

### Evolution possibilities

**Order creation and calculation**

I think the approach I coded works very well for when incoming orders come one by one. However, if the company actually needed to import a whole bunch of orders at the same time, a more optimized solution would be necessary.

**Events**

As said early in the text, I would use events to trigger the use cases. For instance, when creating an order, a "OrderCreated" event could be sent, and the the process of calculating it's commission could be triggered. This would lead to a more decoupled solution.

**Monitoring**

In such a critical system, it's important to monitor everything. I would use datadog or new relic to monitor income calls and calculations, to make sure everything is going well and to be able to fix any problems right away.

## Work method

I used a public github repo and open new branchs and PRs for each step of the way. They can be all seen on: https://github.com/camilacampos/sequra-challenge


## Adding new funcionality

### Refunds
We need to be able to receive refund requests from any order. The refund amount should be deducted from the current pending or processing disbursement.

The refunds contain:
- order_id
- amount
- date

> :warning: We can assume that the amount given on the refund request is always right.

**Solution**

In order to create the refund requests, we must:
* find the order/merchant associated with that refund request
* find the disbursement appropriate for the refund date (considering daily and weekly merchants)
* deduct the refund amount from that disbursement.

![image](https://github.com/camilacampos/sequra-challenge/assets/2309096/023ae374-0c74-49ff-b42d-fea7bd8f13fc)
