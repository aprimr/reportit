package auth

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/aprimr/reportit/internal/middlewares"
	"github.com/aprimr/reportit/internal/utils"
)

type AuthHandler interface {
	Register(w http.ResponseWriter, r *http.Request)
	Login(w http.ResponseWriter, r *http.Request)
	Logout(w http.ResponseWriter, r *http.Request)
	LogoutFromAllDevice(w http.ResponseWriter, r *http.Request)
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
		utils.WriteError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// validate data
	if regReq.Fullname == "" || regReq.Email == "" || regReq.Phone == "" || regReq.Password == "" {
		utils.WriteError(w, http.StatusBadRequest, "all fields are required")
		return
	}
	if !utils.IsValidFullname(regReq.Fullname) {
		utils.WriteError(w, http.StatusBadRequest, "invalid fullname")
		return
	}
	if !utils.IsValidEmail(regReq.Email) {
		utils.WriteError(w, http.StatusBadRequest, "invalid email address")
		return
	}
	if !utils.IsValidPhone(regReq.Phone) {
		utils.WriteError(w, http.StatusBadRequest, "invalid phone number")
		return
	}
	if !utils.IsValidPassword(regReq.Password) {
		utils.WriteError(w, http.StatusBadRequest, "invalid password")
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

	utils.WriteJSON(w, http.StatusCreated, user, "registration successfull")
}

// Login Handler implements the AuthHandler interface and extends the authHandler struct
func (ah *authHandler) Login(w http.ResponseWriter, r *http.Request) {
	var loginReq LoginRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&loginReq)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// validate data
	if loginReq.EmailOrPhone == "" || loginReq.Password == "" {
		utils.WriteError(w, http.StatusBadRequest, "email or phone and password are required")
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

	utils.WriteJSON(w, http.StatusCreated, tokens, "login successfull")
}

// Logout Handler
func (ah *authHandler) Logout(w http.ResponseWriter, r *http.Request) {
	// Get uid from middleware
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	var refreshTokenReq RefreshTokenRequest

	// Parse JSON
	err := json.NewDecoder(r.Body).Decode(&refreshTokenReq)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Call service layer
	err = ah.authService.Logout(r.Context(), refreshTokenReq.RefreshToken)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		return
	}

	utils.WriteJSON(w, http.StatusOK, "", "logout successful")
}

// LogoutFromAllDevice Handler
func (ah *authHandler) LogoutFromAllDevice(w http.ResponseWriter, r *http.Request) {
	// Get uid from middleware
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	// Call service layer
	err := ah.authService.LogoutFromAllDevice(r.Context(), uid)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		return
	}

	utils.WriteJSON(w, http.StatusOK, "", "logged out from all devices")
}

// RefreshToken rotates the access and refresh tokens
func (ah *authHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	var refreshTokenRequest RefreshTokenRequest

	// Decode JSON
	err := json.NewDecoder(r.Body).Decode(&refreshTokenRequest)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "invalid request body")
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

	utils.WriteJSON(w, http.StatusOK, response, "tokens refreshed successfully")
}
