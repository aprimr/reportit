package vote

import (
	"time"

	"github.com/google/uuid"
)

type Vote struct {
	ID          uuid.UUID `json:"id"`
	UID         uuid.UUID `json:"uid"`
	ComplaintID uuid.UUID `json:"complaint_id"`
	IsUpvote    bool      `json:"is_upvote"`
	CreatedAt   time.Time `json:"created_at"`
}

type VoteRequest struct {
	ComplaintID uuid.UUID `json:"complaint_id"`
	IsUpvote    bool      `json:"is_upvote"`
}

type VoteResponse struct {
	Upvotes   int64 `json:"upvotes"`
	Downvotes int64 `json:"downvotes"`
	UserVote  *bool `json:"user_vote"`
}
