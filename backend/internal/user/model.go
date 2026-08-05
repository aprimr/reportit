package user

type UpdateFullnameRequest struct {
	Fullname string `json:"fullname"`
}

type ChangePasswordRequest struct {
	CurrentPassword string `json:"current_password"`
	NewPassword     string `json:"new_password"`
}
