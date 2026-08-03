package utils

import (
	"regexp"
)

// Regex patterns for validation
var (
	fullnameRegex = regexp.MustCompile(`^[a-zA-Z\s]{6,}$`)
	emailRegex    = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	phoneRegex    = regexp.MustCompile(`^9[0-9]{9}$`)
)

// IsValidFullname checks if the provided name is a valid name format.
func IsValidFullname(name string) bool {
	return fullnameRegex.MatchString(name)
}

// IsValidEmail checks if the provided string is a valid email format.
func IsValidEmail(email string) bool {
	return emailRegex.MatchString(email)
}

// IsValidPhone checks if the provided string is a valid phone number.
func IsValidPhone(phone string) bool {
	return phoneRegex.MatchString(phone)
}

// IsValidPassword checks if password meets criteria:
// - At least 8 characters, max 50 characters
// - Contains at least one number
// - Contains at least one uppercase letter
// - Contains at least one lowercase letter
// - Contains at least one symbol from @#!$_*
func IsValidPassword(password string) bool {
	if len(password) < 8 || len(password) > 50 {
		return false
	}

	hasNumber := regexp.MustCompile(`[0-9]`).MatchString(password)
	hasUpper := regexp.MustCompile(`[A-Z]`).MatchString(password)
	hasLower := regexp.MustCompile(`[a-z]`).MatchString(password)
	hasSpecial := regexp.MustCompile(`[@#!$_*]`).MatchString(password)

	return hasNumber && hasUpper && hasLower && hasSpecial
}
