package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/aprimr/reportit/internal/auth"
	"github.com/aprimr/reportit/internal/database"
	"github.com/go-chi/chi/v5"
	"github.com/joho/godotenv"
)

func main() {
	// Init logger
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelDebug}))
	slog.SetDefault(logger)

	// Load env files
	err := godotenv.Load()
	if err != nil {
		logger.Warn("ENV files not found", "error", err)
	}

	// Connect DB
	err = database.ConnectDB()
	if err != nil {
		logger.Error("failed to connect to database", "error", err)
		panic("Failed to connect to database")
	}
	defer database.CloseDB()

	// Middlewares

	// Auth Dependencies
	authRepo := auth.NewAuthRepository(database.DB, logger)
	authService := auth.NewAuthService(authRepo, logger)
	authHandler := auth.NewAuthHandler(authService)

	// Init chi router
	r := chi.NewRouter()

	r.Route("/api/v1", func(r chi.Router) {
		// auth routes
		r.Route("/auth", func(r chi.Router) {
			r.Post("/login", authHandler.Login)
			r.Post("/register", authHandler.Register)
			r.Post("/refresh", authHandler.RefreshToken)
		})
	})

	r.Get("/api/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok","message":"Service is running..."}`))
	})

	// Start the server
	port := os.Getenv("PORT")
	fmt.Println("Server is running on port " + port)
	err = http.ListenAndServe(":"+port, r)
	if err != nil {
		panic("Cannot start the server")
	}
}
