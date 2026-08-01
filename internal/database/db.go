package database

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

var DB *pgxpool.Pool

func ConnectDB() error {
	ctx := context.Background()

	// Get database connection url from env
	dbURL := os.Getenv("DATABASE_URL")

	// Create connection pool
	var err error
	DB, err = pgxpool.New(ctx, dbURL)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	// Ping database
	err = DB.Ping(ctx)
	if err != nil {
		return fmt.Errorf("failed to ping database: %w", err)
	}

	fmt.Println("Connected to database")
	return nil
}

func CloseDB() {
	if DB != nil {
		DB.Close()
	}
}
