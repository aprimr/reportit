package vote

import "errors"

var (
	ErrVoteFailed    = errors.New("failed to vote")
	ErrUnvoteFailed  = errors.New("failed to unvote")
	ErrVoteNotFound  = errors.New("vote not found")
	ErrUnauthorized  = errors.New("unauthorized")
	ErrInvalidVote   = errors.New("invalid vote")
	ErrInternalError = errors.New("something went wrong")
)
