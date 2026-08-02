package utils

import (
	"encoding/json"
	"net/http"
)

type JSONResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
	Data    any    `json:"data,omitempty"`
	Error   string `json:"error,omitempty"`
}

// WriteJSON sends a structured JSON response
func WriteJSON(w http.ResponseWriter, status int, data any, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	response := JSONResponse{
		Success: status >= 200 && status < 300,
		Message: message,
		Data:    data,
	}

	_ = json.NewEncoder(w).Encode(response)
}

// WriteError sends a structured error response
func WriteError(w http.ResponseWriter, status int, errMessage string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	response := JSONResponse{
		Success: false,
		Error:   errMessage,
	}

	_ = json.NewEncoder(w).Encode(response)
}
