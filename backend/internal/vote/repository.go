package vote

import (
	"context"
	"errors"
	"log/slog"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type VoteRepository interface {
	Create(ctx context.Context, uid string, voteReq *VoteRequest) (*Vote, error)
	Update(ctx context.Context, uid string, voteReq *VoteRequest) (*Vote, error)
	Delete(ctx context.Context, uid string, complaintID string) error
	FetchVote(ctx context.Context, uid string, complaintID string) (*Vote, error)
	FetchVoteCounts(ctx context.Context, complaintID string) (int64, int64, error)
}

type voteRepository struct {
	db     *pgxpool.Pool
	logger *slog.Logger
}

func NewVoteRepository(db *pgxpool.Pool, logger *slog.Logger) VoteRepository {
	return &voteRepository{db: db, logger: logger}
}

// Creates a new vote
func (vr *voteRepository) Create(ctx context.Context, uid string, voteReq *VoteRequest) (*Vote, error) {
	var vote Vote
	query := `INSERT INTO votes (uid, complaint_id, is_upvote) VALUES ($1, $2, $3) RETURNING id, uid, complaint_id, is_upvote, created_at`

	err := vr.db.QueryRow(ctx, query, uid, voteReq.ComplaintID, voteReq.IsUpvote).Scan(&vote.ID, &vote.UID, &vote.ComplaintID, &vote.IsUpvote, &vote.CreatedAt)
	if err != nil {
		vr.logger.Error("failed to create vote", "error", err, "uid", uid, "complaint_id", voteReq.ComplaintID)
		return nil, ErrVoteFailed
	}

	return &vote, nil
}

// Updates an existing vote from upvote to downvote or vice versa
func (vr *voteRepository) Update(ctx context.Context, uid string, voteReq *VoteRequest) (*Vote, error) {
	var vote Vote
	query := `UPDATE votes SET is_upvote = $1 WHERE uid = $2 AND complaint_id = $3 RETURNING id, uid, complaint_id, is_upvote, created_at`

	err := vr.db.QueryRow(ctx, query, voteReq.IsUpvote, uid, voteReq.ComplaintID).Scan(&vote.ID, &vote.UID, &vote.ComplaintID, &vote.IsUpvote, &vote.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrVoteNotFound
		}

		vr.logger.Error("failed to update vote", "error", err, "uid", uid, "complaint_id", voteReq.ComplaintID)
		return nil, ErrVoteFailed
	}

	return &vote, nil
}

// Deletes an existing vote
func (vr *voteRepository) Delete(ctx context.Context, uid string, complaintID string) error {
	query := `DELETE FROM votes WHERE uid = $1 AND complaint_id = $2`

	cmdTag, err := vr.db.Exec(ctx, query, uid, complaintID)
	if err != nil {
		vr.logger.Error("failed to delete vote", "error", err, "uid", uid, "complaint_id", complaintID)
		return ErrUnvoteFailed
	}

	if cmdTag.RowsAffected() == 0 {
		return ErrVoteNotFound
	}

	return nil
}

// Fetches a user's vote on a complaint
func (vr *voteRepository) FetchVote(ctx context.Context, uid string, complaintID string) (*Vote, error) {
	var vote Vote
	query := `SELECT id, uid, complaint_id, is_upvote, created_at FROM votes WHERE uid = $1 AND complaint_id = $2`

	err := vr.db.QueryRow(ctx, query, uid, complaintID).Scan(&vote.ID, &vote.UID, &vote.ComplaintID, &vote.IsUpvote, &vote.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrVoteNotFound
		}

		vr.logger.Error("failed to fetch vote", "error", err, "uid", uid, "complaint_id", complaintID)
		return nil, ErrInternalError
	}

	return &vote, nil
}

// Fetches vote counts for a particular complaint
func (vr *voteRepository) FetchVoteCounts(ctx context.Context, complaintID string) (int64, int64, error) {
	var upvotes int64
	var downvotes int64

	query := `SELECT COUNT(*) FILTER (WHERE is_upvote = true), COUNT(*) FILTER (WHERE is_upvote = false) FROM votes WHERE complaint_id = $1`

	err := vr.db.QueryRow(ctx, query, complaintID).Scan(&upvotes, &downvotes)
	if err != nil {
		vr.logger.Error("failed to fetch vote counts", "error", err, "complaint_id", complaintID)
		return 0, 0, ErrInternalError
	}

	return upvotes, downvotes, nil
}
