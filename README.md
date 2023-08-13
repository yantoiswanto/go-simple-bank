# Golang Simple Bank

---------------------
* [Design DB schema and generate SQL code with dbdiagram.io](#design-db-schema-and-generate-sql-code-with-dbdiagramio)
* [Install & use Docker + Postgres](#install--use-docker--postgres)
* [Install database migration](#install-database-migration)
* [Setup Makefile](#setup-makefile)
* [Generate CRUD Golang code from SQL | Compare db/sql, gorm, sqlx & sqlc](#generate-crud-golang-code-from-sql--compare-dbsql-gorm-sqlx--sqlc)
  * [DATABASE / SQL](#database--sql) 
  * [GORM](#gorm)
  * [SQLX](#sqlx)
  * [SQLC](#sqlc)
_____________________

## Design DB schema and generate SQL code with dbdiagram.io
```
Table accounts as A {
  id bigserial [primary key]
  owner varchar [not null]
  balance bigint [not null]
  currency varchar [not null]
  created_at timestamptz  [not null, default: `now()`]
  
  Indexes {
    owner
  }
}

Table entries {
  id bigserial [primary key]
  account_id bigint [ref: > A.id, not null]
  amount bigint [not null, note:'can be negative or positive']
  created_at timestamptz  [not null, default: `now()`]

  Indexes {
    account_id
  }
}

Table transfers {
  id bigserial [primary key]
  from_account_id bigint [ref: > A.id, not null]
  to_account_id bigint [ref: > A.id, not null]
  amount bigint [not null, note:'must be positive']
  created_at timestamptz  [not null, default: `now()`]

  Indexes {
    from_account_id
    to_account_id
    (from_account_id, to_account_id)
  }
}

```
```postgresql
CREATE TABLE "accounts" ( "id" bigserial PRIMARY KEY, "owner" VARCHAR NOT NULL, "balance" BIGINT NOT NULL, "currency" VARCHAR NOT NULL, "created_at" TIMESTAMPTZ NOT NULL DEFAULT ( now( ) ) );
CREATE TABLE "entries" ( "id" bigserial PRIMARY KEY, "account_id" BIGINT NOT NULL, "amount" BIGINT NOT NULL, "created_at" TIMESTAMPTZ NOT NULL DEFAULT ( now( ) ) );
CREATE TABLE "transfers" ( "id" bigserial PRIMARY KEY, "from_account_id" BIGINT NOT NULL, "to_account_id" BIGINT NOT NULL, "amount" BIGINT NOT NULL, "created_at" TIMESTAMPTZ NOT NULL DEFAULT ( now( ) ) );
CREATE INDEX ON "accounts" ( "owner" );
CREATE INDEX ON "entries" ( "account_id" );
CREATE INDEX ON "transfers" ( "from_account_id" );
CREATE INDEX ON "transfers" ( "to_account_id" );
CREATE INDEX ON "transfers" ( "from_account_id", "to_account_id" );
COMMENT ON COLUMN "entries"."amount" IS 'can be negative or positive';
COMMENT ON COLUMN "transfers"."amount" IS 'must be positive';
ALTER TABLE "entries" ADD FOREIGN KEY ( "account_id" ) REFERENCES "accounts" ( "id" );
ALTER TABLE "transfers" ADD FOREIGN KEY ( "from_account_id" ) REFERENCES "accounts" ( "id" );
ALTER TABLE "transfers" ADD FOREIGN KEY ( "to_account_id" ) REFERENCES "accounts" ( "id" );
```

## Install & use Docker + Postgres
* Install Docker (https://docs.docker.com/desktop/)
* Install Postgresql 
```bash
docker pull postgres:14-alpine
```
## Install database migration
```shell
brew install golang-migrate
```
## Setup Makefile
```makefile
postgres:
	docker run --name postgres14 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:14-alpine

cretedb:
	docker exec -it postgres14 createdb --username=root --owner=root db_simple_bank

dropdb:
	docker exec -it postgres14 dropdb db_simple_bank

migrateup:
	migrate -path db/migration -database "postgresql://postgres:admin@localhost:5432/db_simple_bank?sslmode=disable" -verbose up

migratedown:
	migrate -path db/migration -database "postgresql://postgres:admin@localhost:5432/db_simple_bank?sslmode=disable" -verbose down

.PHONY: postgres cretedb dropdb migrateup migratedown
```

## Generate CRUD Golang code from SQL | Compare db/sql, gorm, sqlx & sqlc

### DATABASE / SQL
* Very fast & straightforward
* Manual mapping SQL fields to variables
* Easy to make mistakes, not caught until runtime

### [**GORM**](https://github.com/go-gorm/gorm)
* CRUD functions already implemented very short production code
* Must learn to write queries using gorm's function
* Run slowly on high load

### [**SQLX**](https://github.com/jmoiron/sqlx)
* Quite fast & easy to use
* Fields mapping via query text & struct tags
* Failure won't occur runtime

### [**SQLC**](https://github.com/sqlc-dev/sqlc)

* very fast & easy to use
* Automatic code generation
* Catch SQL query errors before generation codes

#### SQLC Install
```shell
brew install sqlc
```