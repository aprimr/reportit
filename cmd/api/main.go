package main

import (
	"fmt"
	"net/http"

	"github.com/aprimr/ccms/internal/database"
	"github.com/go-chi/chi/v5"
	"github.com/joho/godotenv"
)

func main() {
	// Load env files
	err := godotenv.Load()
	if err != nil {
		panic("Error loading env")
	}

	// Connect DB
	err = database.ConnectDB()
	if err != nil {
		panic("Failed to connect to database")
	}

	r := chi.NewRouter()

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello world"))
	})

	// Start the server
	port := ":8000"
	fmt.Println("Server is running on port " + port)
	err = http.ListenAndServe(port, r)
	if err != nil {
		panic("Cannot start the server")
	}
}
