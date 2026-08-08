package complaint

import "errors"

var (
	ErrComplaintCreateFailed = errors.New("failed to create complaint")
	ErrComplaintDeleteFailed = errors.New("failed to delete complaint")
	ErrComplaintNotFound     = errors.New("complaint not found")
	ErrAlreadyVoted          = errors.New("already voted on this complaint")
	ErrInvalidStatus         = errors.New("invalid complaint status")
	ErrUnauthorized          = errors.New("unauthorized")
	ErrInternalError         = errors.New("something went wrong")
)
