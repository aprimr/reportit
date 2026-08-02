package utils

import (
	"crypto/sha256"
	"encoding/hex"
)

func HashString(text string) (string, error) {
	// Hash long string using SHA 256 algo
	hasher := sha256.New()
	hasher.Write([]byte(text))
	shaHash := hasher.Sum(nil)
	return hex.EncodeToString(shaHash), nil
}

func CheckString(text, hashedText string) bool {
	hash, err := HashString(text)
	if err != nil {
		return false
	}
	return hash == hashedText
}
