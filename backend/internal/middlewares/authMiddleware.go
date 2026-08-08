package middlewares

import (
	"context"
	"net/http"
	"strings"

	"github.com/aprimr/reportit/internal/utils"
)

type contextKey string

const (
	UserUidKey         contextKey = "uid"
	UserEmailKey       contextKey = "email"
	UserPhoneKey       contextKey = "phone"
	UserAccessTokenKey contextKey = "access_token"
)

func AuthMiddleware(userAuthMiddleware bool) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Extract Auth header from request
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				utils.WriteError(w, http.StatusUnauthorized, "auth header is missing")
				return
			}

			// Extract access token from auth header
			parts := strings.Split(authHeader, " ")
			if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
				utils.WriteError(w, http.StatusUnauthorized, "invalid authorization header format")
				return
			}
			tokenString := parts[1]

			// Verify  JWT token
			claims, err := utils.ValidateToken(tokenString, false)
			if err != nil {
				utils.WriteError(w, http.StatusUnauthorized, "invalid or expired access token")
				return
			}

			// verify user or admin role
			role, _ := claims["role"].(string)
			if userAuthMiddleware && role != "user" {
				utils.WriteError(w, http.StatusForbidden, "access denied")
				return
			} else if !userAuthMiddleware && role != "admin" {
				utils.WriteError(w, http.StatusForbidden, "access denied")
				return
			}

			ctx := context.WithValue(r.Context(), UserUidKey, claims["uid"])
			ctx = context.WithValue(ctx, UserEmailKey, claims["email"])
			ctx = context.WithValue(ctx, UserPhoneKey, claims["phone"])

			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// Helper functions
func GetUidFromContext(ctx context.Context) string {
	if uid, ok := ctx.Value(UserUidKey).(string); ok {
		return uid
	}
	return ""
}

func GetEmailFromContext(ctx context.Context) string {
	if email, ok := ctx.Value(UserEmailKey).(string); ok {
		return email
	}
	return ""
}

func GetPhoneFromContext(ctx context.Context) string {
	if phone, ok := ctx.Value(UserPhoneKey).(string); ok {
		return phone
	}
	return ""
}
