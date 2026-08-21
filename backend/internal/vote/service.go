package vote

import (
	"context"
	"errors"
	"log/slog"
)

type VoteService interface {
	Vote(ctx context.Context, uid string, voteReq *VoteRequest) (*Vote, error)
	GetVotes(ctx context.Context, uid string, complaintID string) (*VoteResponse, error)
}

type voteService struct {
	repo   VoteRepository
	logger *slog.Logger
}

func NewVoteService(repo VoteRepository, logger *slog.Logger) VoteService {
	return &voteService{
		repo:   repo,
		logger: logger,
	}
}

func (vs *voteService) Vote(ctx context.Context, uid string, voteReq *VoteRequest) (*Vote, error) {
	// Check if user has already voted for that particular complaint
	existingVote, err := vs.repo.FetchVote(ctx, uid, voteReq.ComplaintID.String())

	if err != nil && !errors.Is(err, ErrVoteNotFound) {
		vs.logger.Error("failed to fetch existing vote", "error", err, "uid", uid, "complaint_id", voteReq.ComplaintID)
		return nil, ErrInternalError
	}

	// If user has not voted yet, then create a new vote
	if errors.Is(err, ErrVoteNotFound) {
		return vs.repo.Create(ctx, uid, voteReq)
	}

	// If user clicked upvote or downvote again, then remove the vote
	if existingVote.IsUpvote == voteReq.IsUpvote {
		err := vs.repo.Delete(ctx, uid, voteReq.ComplaintID.String())
		if err != nil {
			vs.logger.Error("failed to unvote", "error", err, "uid", uid, "complaint_id", voteReq.ComplaintID)
			return nil, err
		}

		return nil, nil
	}

	// If user changed from upvote to downvote or vice versa
	return vs.repo.Update(ctx, uid, voteReq)
}

func (vs *voteService) GetVotes(ctx context.Context, uid string, complaintID string) (*VoteResponse, error) {
	upvotes, downvotes, err := vs.repo.FetchVoteCounts(ctx, complaintID)
	if err != nil {
		vs.logger.Error("failed to fetch vote counts", "error", err, "complaint_id", complaintID)
		return nil, err
	}

	var userVote *bool

	vote, err := vs.repo.FetchVote(ctx, uid, complaintID)
	if err != nil && !errors.Is(err, ErrVoteNotFound) {
		vs.logger.Error("failed to fetch user vote", "error", err, "uid", uid, "complaint_id", complaintID)
		return nil, ErrInternalError
	}

	if vote != nil {
		userVote = &vote.IsUpvote
	}

	return &VoteResponse{Upvotes: upvotes, Downvotes: downvotes, UserVote: userVote}, nil
}
