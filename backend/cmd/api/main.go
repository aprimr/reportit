package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/aprimr/reportit/internal/auth"
	"github.com/aprimr/reportit/internal/complaint"
	"github.com/aprimr/reportit/internal/database"
	"github.com/aprimr/reportit/internal/middlewares"
	"github.com/aprimr/reportit/internal/user"
	"github.com/aprimr/reportit/internal/utils"
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

	// Init Cloudinary
	err = utils.InitCloudinary()
	if err != nil {
		logger.Error("failed to initialize cloudinary", "error", err)
	}

	// Auth Dependencies
	authRepo := auth.NewAuthRepository(database.DB, logger)
	authService := auth.NewAuthService(authRepo, logger)
	authHandler := auth.NewAuthHandler(authService)

	// User Dependencies
	userRepo := user.NewUserRepository(database.DB, logger)
	userService := user.NewUserService(userRepo, logger)
	userHandler := user.NewUserHandler(userService)

	// Complaint Dependencies
	complaintRepo := complaint.NewComplaintRepository(database.DB, logger)
	complaintService := complaint.NewComplaintService(logger, complaintRepo)
	complaintHandler := complaint.NewComplaintHandler(complaintService)

	// Init chi router
	r := chi.NewRouter()

	r.Route("/api/v1", func(r chi.Router) {
		// auth routes
		r.Route("/auth", func(r chi.Router) {
			r.Post("/login", authHandler.Login)
			r.Post("/register", authHandler.Register)
			r.Post("/refresh", authHandler.RefreshToken)

			// protected auth routes
			r.Group(func(r chi.Router) {
				r.Use(middlewares.AuthMiddleware(true))

				r.Post("/logout", authHandler.Logout)
				r.Post("/logout-all", authHandler.LogoutFromAllDevice)
			})
		})

		// protected user routes
		r.Route("/user", func(r chi.Router) {
			r.Use(middlewares.AuthMiddleware(true))

			r.Get("/", userHandler.FetchProfile)
			r.Patch("/fullname", userHandler.UpdateFullname)
			r.Patch("/password", userHandler.ChangePassword)
		})

		// protected complaint routes
		r.Route("/complaint", func(r chi.Router) {
			r.Use(middlewares.AuthMiddleware(true))

			r.Post("/", complaintHandler.CreateComplaint)
			r.Delete("/", complaintHandler.DeleteComplaint)
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
