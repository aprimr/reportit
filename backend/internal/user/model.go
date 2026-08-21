package user

import "github.com/aprimr/reportit/internal/auth"

type UserProfile struct {
	User           auth.User          `json:"user"`
	ComplaintStats UserComplaintStats `json:"complaint_stats"`
}

type UserComplaintStats struct {
	Open     int64 `json:"open"`
	Verified int64 `json:"verified"`
	Resolved int64 `json:"resolved"`
	Rejected int64 `json:"rejected"`
	Total    int64 `json:"total"`
}

type UpdateFullnameRequest struct {
	Fullname string `json:"fullname"`
}

type ChangePasswordRequest struct {
	CurrentPassword string `json:"current_password"`
	NewPassword     string `json:"new_password"`
}
