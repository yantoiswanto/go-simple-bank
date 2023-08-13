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

sqlc:
	sqlc generate

test:
	go test -v -cover ./..

.PHONY: postgres cretedb dropdb migrateup migratedown test