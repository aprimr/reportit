package complaint

import (
	"context"
	"errors"
	"log/slog"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ComplaintRepository interface {
	Create(ctx context.Context, uid string, complaintReq CreateComplaintRequest) (*Complaint, error)
	FetchById(ctx context.Context, id string) (*Complaint, error)
	Delete(ctx context.Context, id string) error
}

type complaintRepository struct {
	db     *pgxpool.Pool
	logger *slog.Logger
}

func NewComplaintRepository(db *pgxpool.Pool, logger *slog.Logger) ComplaintRepository {
	return &complaintRepository{
		db:     db,
		logger: logger,
	}
}

// Inserts a new row for complaints in complaints table
func (cr *complaintRepository) Create(ctx context.Context, uid string, complaintReq CreateComplaintRequest) (*Complaint, error) {
	var complaint Complaint

	query := `INSERT INTO complaints (uid, title, description, category, image_urls, longitude, latitude, is_public) VALUES($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id, uid, title, description, category, image_urls, longitude, latitude, is_public, status, admin_remarks, verified_at, rejected_at, resolved_at, created_at`
	err := cr.db.QueryRow(ctx, query, uid, complaintReq.Title, complaintReq.Description, complaintReq.Category, complaintReq.ImageUrls, complaintReq.Longitude, complaintReq.Latitude, complaintReq.IsPublic).Scan(
		&complaint.Id,
		&complaint.Uid,
		&complaint.Title,
		&complaint.Description,
		&complaint.Category,
		&complaint.ImageUrls,
		&complaint.Longitude,
		&complaint.Latitude,
		&complaint.IsPublic,
		&complaint.Status,
		&complaint.AdminRemarks,
		&complaint.VerifiedAt,
		&complaint.RejectedAt,
		&complaint.ResolvedAt,
		&complaint.CreatedAt,
	)
	if err != nil {
		cr.logger.Error("failed to insert complaint in database", "error", err, "uid", uid)
		return nil, ErrComplaintCreateFailed
	}

	return &complaint, nil
}

// Fetches a complaint from the database by its id
func (cr *complaintRepository) FetchById(ctx context.Context, id string) (*Complaint, error) {
	var complaint Complaint

	query := `SELECT id, uid, title, description, category, image_urls, longitude, latitude, is_public, status, admin_remarks, verified_at, rejected_at, resolved_at, created_at FROM complaints WHERE id=$1`
	err := cr.db.QueryRow(ctx, query, id).Scan(
		&complaint.Id,
		&complaint.Uid,
		&complaint.Title,
		&complaint.Description,
		&complaint.Category,
		&complaint.ImageUrls,
		&complaint.Longitude,
		&complaint.Latitude,
		&complaint.IsPublic,
		&complaint.Status,
		&complaint.AdminRemarks,
		&complaint.VerifiedAt,
		&complaint.RejectedAt,
		&complaint.ResolvedAt,
		&complaint.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrComplaintNotFound
		}
		cr.logger.Error("failed to fetch complaint from database", "error", err)
		return nil, ErrInternalError
	}

	return &complaint, nil
}

// Deletes a row from the complaints table
func (cr *complaintRepository) Delete(ctx context.Context, id string) error {
	query := `DELETE FROM complaints WHERE id=$1`

	cmdTag, err := cr.db.Exec(ctx, query, id)
	if err != nil {
		cr.logger.Error("failed to delete complaint from database", "error", err)
		return ErrComplaintDeleteFailed
	}
	if cmdTag.RowsAffected() == 0 {
		return ErrComplaintNotFound
	}

	return nil
}
