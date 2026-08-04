package auth

import "errors"

var (
	ErrEmailOrPhoneTaken = errors.New("email or phone is already taken")
	ErrInvalidCreds      = errors.New("invalid credentials")
	ErrTokenInvalid      = errors.New("invalid or expired refresh token")
	ErrInternalError     = errors.New("internal server error")
	ErrSessionExpired    = errors.New("session expired")
)
