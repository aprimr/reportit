package user

import "errors"

var (
	ErrUserNotFound    = errors.New("user not found")
	ErrInvalidPassword = errors.New("incorrect password")
	ErrUpdateFailed    = errors.New("failed to update user")
	ErrInternalError   = errors.New("something went wrong")
	ErrUnauthorized    = errors.New("unauthorized")
)
