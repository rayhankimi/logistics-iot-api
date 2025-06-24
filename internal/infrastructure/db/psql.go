package db

import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v5"
	"log"
	"os"
)

var ctx = context.Background()

func PostgresInit() {
	url := fmt.Sprintf(
		"postgres://%s:%s@%s:%s/%s?sslmode=disable",
		os.Getenv("POSTGRES_USER"),
		os.Getenv("POSTGRES_PASSWORD"),
		"localhost",
		os.Getenv("POSTGRES_PORT"),
		os.Getenv("POSTGRES_DB"))

	conn, err := pgx.Connect(ctx, url)
	if err != nil {
		log.Fatal("[DB]     - ERROR Connecting to PostgreSQL : ", err)
	}

	log.Println("[DB]     - Connected to PostgreSQL")

	defer func(conn *pgx.Conn, ctx context.Context) {
		err := conn.Close(ctx)
		if err != nil {
			log.Fatal("[DB]     - Error closing PostgreSQL : ", err)
		}
	}(conn, ctx)
}
