package complaint

import (
	"context"
	"log/slog"

	"github.com/jackc/pgx/v5/pgxpool"
)

type ComplaintRepository interface {
	Create(ctx context.Context, uid string, complaintReq CreateComplaintRequest) (*Complaint, error)
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

// Create a new complaint
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
		cr.logger.Error("failed to create complaint", "error", err, "uid", uid)
		return nil, ErrComplaintCreateFailed
	}

	return &complaint, nil
}
