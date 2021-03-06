define MYSQL_SQL
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
  username VARCHAR(32) NOT NULL,
  email VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE INDEX uniq_email (email)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB;
endef

define PSQL_SQL
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(32) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL
);
endef

export MYSQL_SQL
MYSQL := "$$MYSQL_SQL"

export PSQL_SQL
PSQL := "$$PSQL_SQL"

INSERTS := "INSERT INTO users (username, email) VALUES ('gopher', 'gopher@go.com'), ('john', 'john@doe.com'), ('jane', 'jane@doe.com');"

test: mysql psql
	@go test -race -tags "mysql psql"

mysql:
	@mysql -u root -e 'DROP DATABASE IF EXISTS txdb_test'
	@mysql -u root -e 'CREATE DATABASE txdb_test'
	@mysql -u root txdb_test -e $(MYSQL)
	@mysql -u root txdb_test -e $(INSERTS)

psql:
	@psql -U postgres -c 'DROP DATABASE IF EXISTS txdb_test'
	@psql -U postgres -c 'CREATE DATABASE txdb_test'
	@psql -U postgres txdb_test -c $(PSQL)
	@psql -U postgres txdb_test -c $(INSERTS)

.PHONY: test mysql psql
