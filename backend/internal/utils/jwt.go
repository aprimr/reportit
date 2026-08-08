package utils

import (
	"errors"
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Generates a short lived access token valid for 10 minutes
func GenerateAccessToken(uid, email, phone, role string) (string, error) {
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		return "", fmt.Errorf("JWT SECRET not set")
	}

	claims := jwt.MapClaims{
		"uid":   uid,
		"email": email,
		"phone": phone,
		"role":  role,
		"type":  "access",
		"exp":   time.Now().Add(time.Minute * 10 * 1000).Unix(), // TODO: Update duration to 10 minutes
		"iat":   time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(jwtSecret))
}

// Generates a long lived refresh token valid for 30 days
func GenerateRefreshToken(uid string) (string, error) {
	refreshSecret := os.Getenv("REFRESH_TOKEN")
	if refreshSecret == "" {
		return "", fmt.Errorf("REFRESH TOKEN not set")
	}

	claims := jwt.MapClaims{
		"uid":  uid,
		"type": "refresh",
		"exp":  time.Now().Add(time.Hour * 24 * 30).Unix(),
		"iat":  time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(refreshSecret))
}

// Validates the tokens and return token claims
func ValidateToken(tokenString string, isRefresh bool) (jwt.MapClaims, error) {
	secretKey := os.Getenv("JWT_SECRET")
	if isRefresh {
		secretKey = os.Getenv("REFRESH_TOKEN")
	}

	token, err := jwt.Parse(tokenString, func(t *jwt.Token) (any, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}

		return []byte(secretKey), nil
	})

	if err != nil {
		return nil, fmt.Errorf("failed to parse token: %w", err)
	}

	// Extract and validate the claims
	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid token")
}
