package auth

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/aprimr/reportit/internal/utils"
)

type AuthHandler interface {
	Register(w http.ResponseWriter, r *http.Request)
	Login(w http.ResponseWriter, r *http.Request)
	RefreshToken(w http.ResponseWriter, r *http.Request)
}

type authHandler struct {
	authService AuthService
}

func NewAuthHandler(authService AuthService) AuthHandler {
	return &authHandler{
		authService: authService,
	}
}

// Register Handler implements the AuthHandler interface and extends the authHandler struct
func (ah *authHandler) Register(w http.ResponseWriter, r *http.Request) {
	var regReq RegisterRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&regReq)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// validate data
	if regReq.Fullname == "" || regReq.Email == "" || regReq.Phone == "" || regReq.Password == "" {
		utils.WriteError(w, http.StatusBadRequest, "All fields are required")
		return
	}
	if !utils.IsValidFullname(regReq.Fullname) {
		utils.WriteError(w, http.StatusBadRequest, "Invalid fullname")
		return
	}
	if !utils.IsValidEmail(regReq.Email) {
		utils.WriteError(w, http.StatusBadRequest, "Invalid email address")
		return
	}
	if !utils.IsValidPhone(regReq.Phone) {
		utils.WriteError(w, http.StatusBadRequest, "Invalid phone number")
		return
	}
	if !utils.IsValidPassword(regReq.Password) {
		utils.WriteError(w, http.StatusBadRequest, "Invalid password. Please match the password requirements.")
		return
	}

	// Call service layer
	user, err := ah.authService.Register(r.Context(), regReq)
	if err != nil {
		if errors.Is(err, ErrEmailOrPhoneTaken) {
			utils.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		utils.WriteError(w, http.StatusInternalServerError, err.Error())
		return
	}

	utils.WriteJSON(w, http.StatusCreated, user, "Registration successfull")
}

// Login Handler implements the AuthHandler interface and extends the authHandler struct
func (ah *authHandler) Login(w http.ResponseWriter, r *http.Request) {
	var loginReq LoginRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&loginReq)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// validate data
	if loginReq.EmailOrPhone == "" || loginReq.Password == "" {
		utils.WriteError(w, http.StatusBadRequest, "Email or phone and password are required")
		return
	}

	// Call service layer
	accessToken, refreshToken, err := ah.authService.Login(r.Context(), loginReq)
	if err != nil {
		if errors.Is(err, ErrInvalidCreds) {
			utils.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		utils.WriteError(w, http.StatusInternalServerError, err.Error())
		return
	}

	tokens := map[string]string{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	}

	utils.WriteJSON(w, http.StatusCreated, tokens, "Login successfull")
}

// RefreshToken rotates the access and refresh tokens
func (ah *authHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	var refreshTokenRequest RefreshTokenRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&refreshTokenRequest)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Call service layer
	accessToken, refreshToken, err := ah.authService.RefreshToken(context.Background(), refreshTokenRequest.RefreshToken)
	if err != nil {
		if errors.Is(err, ErrTokenInvalid) || errors.Is(err, ErrSessionExpired) {
			utils.WriteError(w, http.StatusUnauthorized, err.Error())
			return
		}
		utils.WriteError(w, http.StatusInternalServerError, err.Error())
		return
	}

	response := map[string]string{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	}

	utils.WriteJSON(w, http.StatusOK, response, "Tokens refreshed successfully")
}
