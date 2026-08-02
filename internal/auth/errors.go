package auth

import "errors"

var (
	ErrEmailOrPhoneTaken = errors.New("email or phone is already taken")
	ErrInvalidCreds      = errors.New("invalid credentials")
	ErrTokenExpired      = errors.New("refresh token has expired")
	ErrTokenInvalid      = errors.New("invalid or expired refresh token")
	ErrInternalError     = errors.New("internal server error")
)
