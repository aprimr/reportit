package utils

import (
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
		"exp":   time.Now().Add(time.Minute * 10).Unix(),
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
