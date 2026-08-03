package auth

import (
	"encoding/json"
	"net/http"

	"github.com/aprimr/ccms/internal/utils"
)

type AuthHandler interface {
	Register(w http.ResponseWriter, r *http.Request)
	Login(w http.ResponseWriter, r *http.Request)
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
		utils.WriteError(w, http.StatusBadRequest, "Invalid JSON")
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
		utils.WriteError(w, http.StatusBadRequest, err.Error())
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
		utils.WriteError(w, http.StatusBadRequest, "Invalid JSON")
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
		utils.WriteError(w, http.StatusBadRequest, err.Error())
		return
	}

	tokens := map[string]string{
		"accessToken":  accessToken,
		"refreshToken": refreshToken,
	}

	utils.WriteJSON(w, http.StatusCreated, tokens, "Login successfull")
}
