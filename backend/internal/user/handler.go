package user

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/aprimr/reportit/internal/middlewares"
	"github.com/aprimr/reportit/internal/utils"
)

type UserHandler interface {
	FetchProfile(w http.ResponseWriter, r *http.Request)
	UpdateFullname(w http.ResponseWriter, r *http.Request)
	ChangePassword(w http.ResponseWriter, r *http.Request)
}

type userHandler struct {
	userService UserService
}

func NewUserHandler(userService UserService) UserHandler {
	return &userHandler{
		userService: userService,
	}
}

func (uh *userHandler) FetchProfile(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	// Call service
	user, stats, err := uh.userService.FetchProfile(r.Context(), uid)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			utils.WriteError(w, http.StatusNotFound, ErrUserNotFound.Error())
			return
		}

		utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		return
	}

	UserProfile := UserProfile{
		User:           *user,
		ComplaintStats: *stats,
	}

	utils.WriteJSON(w, http.StatusOK, UserProfile, "user fetched successfully")
}

func (uh *userHandler) UpdateFullname(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	// Parse JSON
	var updateReq UpdateFullnameRequest
	err := json.NewDecoder(r.Body).Decode(&updateReq)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Validate data
	if updateReq.Fullname == "" {
		utils.WriteError(w, http.StatusBadRequest, "fullname is required")
		return
	}
	if !utils.IsValidFullname(updateReq.Fullname) {
		utils.WriteError(w, http.StatusBadRequest, "invalid fullname")
		return
	}

	// Call service
	err = uh.userService.UpdateFullname(r.Context(), uid, updateReq.Fullname)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			utils.WriteError(w, http.StatusNotFound, ErrUserNotFound.Error())
			return
		}

		utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		return
	}

	utils.WriteJSON(w, http.StatusOK, nil, "fullname updated successfully")
}

func (uh *userHandler) ChangePassword(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	// Parse JSON
	var changeReq ChangePasswordRequest
	err := json.NewDecoder(r.Body).Decode(&changeReq)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Validate data
	if changeReq.CurrentPassword == "" || changeReq.NewPassword == "" {
		utils.WriteError(w, http.StatusBadRequest, "all fields are required")
		return
	}
	if !utils.IsValidPassword(changeReq.NewPassword) {
		utils.WriteError(w, http.StatusBadRequest, "invalid new password")
		return
	}

	// Call service
	err = uh.userService.ChangePassword(r.Context(), uid, changeReq.CurrentPassword, changeReq.NewPassword)
	if err != nil {
		switch {
		case errors.Is(err, ErrInvalidPassword):
			utils.WriteError(w, http.StatusUnauthorized, ErrInvalidPassword.Error())

		case errors.Is(err, ErrUserNotFound):
			utils.WriteError(w, http.StatusNotFound, ErrUserNotFound.Error())

		default:
			utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		}
		return
	}

	utils.WriteJSON(w, http.StatusOK, nil, "password updated successfully")
}
