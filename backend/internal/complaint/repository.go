package complaint

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ComplaintRepository interface {
	Create(ctx context.Context, uid string, complaintReq CreateComplaintRequest) (*Complaint, error)
	FetchById(ctx context.Context, id string) (*Complaint, error)
	Delete(ctx context.Context, id string) error
	FetchUserComplaints(ctx context.Context, params ComplaintFetchParams) ([]Complaint, error)
	FetchAllComplaints(ctx context.Context, params ComplaintFetchParams) ([]Complaint, error)
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

// Fetches user's complaints
func (cr *complaintRepository) FetchUserComplaints(ctx context.Context, params ComplaintFetchParams) ([]Complaint, error) {
	query := `SELECT id, uid, title, description, category, image_urls, longitude, latitude, is_public, status, admin_remarks, verified_at, rejected_at, resolved_at, created_at FROM complaints WHERE uid=$1`

	args := []any{params.Uid}
	argIdx := 2

	// Append search to the query
	if params.Search != "" {
		query += fmt.Sprintf(` AND (title ILIKE $%d OR description ILIKE $%d)`, argIdx, argIdx)
		args = append(args, "%"+params.Search+"%")
		argIdx++
	}

	// Append status to query
	if params.Status != "" {
		query += fmt.Sprintf(` AND status=$%d`, argIdx)
		args = append(args, params.Status)
		argIdx++
	}

	// Determine cursor operator based on sort order
	cursorOp := "<"
	if params.Sort == "oldest" {
		cursorOp = ">"
	}

	// Append cursor index to query
	if params.Cursor != "" {
		query += fmt.Sprintf(" AND created_at %s $%d", cursorOp, argIdx)
		args = append(args, params.Cursor)
		argIdx++
	}

	// Append sort to query
	switch params.Sort {
	case "latest":
		query += " ORDER BY created_at DESC"
	case "oldest":
		query += " ORDER BY created_at ASC"
	default:
		query += " ORDER BY created_at DESC"
	}

	query += fmt.Sprintf(" LIMIT $%d", argIdx)
	args = append(args, params.Limit)

	// Fire query
	rows, err := cr.db.Query(ctx, query, args...)
	if err != nil {
		cr.logger.Error("failed to fetch complaints from database", "error", err, "uid", params.Uid)
		return nil, ErrInternalError
	}
	defer rows.Close()

	// Scan rows
	var complaints []Complaint
	for rows.Next() {
		var complaint Complaint
		err := rows.Scan(
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
			return nil, ErrInternalError
		}

		complaints = append(complaints, complaint)
	}

	return complaints, nil
}

// Fetches all complaints
func (cr *complaintRepository) FetchAllComplaints(ctx context.Context, params ComplaintFetchParams) ([]Complaint, error) {
	// Base query with a dummy condition so we can safely chain AND clauses
	query := `SELECT id, uid, title, description, category, image_urls, longitude, latitude, is_public, status, admin_remarks, verified_at, rejected_at, resolved_at, created_at FROM complaints WHERE 1=1`

	args := []any{}
	argIdx := 1

	// If not an admin, restrict to public complaints only
	if !params.IsAdmin {
		query += ` AND is_public = true`
	}

	// Append search to the query
	if params.Search != "" {
		query += fmt.Sprintf(` AND (title ILIKE $%d OR description ILIKE $%d)`, argIdx, argIdx)
		args = append(args, "%"+params.Search+"%")
		argIdx++
	}

	// Append status to query
	if params.Status != "" {
		query += fmt.Sprintf(` AND status = $%d`, argIdx)
		args = append(args, params.Status)
		argIdx++
	}

	// Determine cursor operator based on sort order
	cursorOp := "<"
	if params.Sort == "oldest" {
		cursorOp = ">"
	}

	// Append cursor index to query
	if params.Cursor != "" {
		query += fmt.Sprintf(" AND created_at %s $%d", cursorOp, argIdx)
		args = append(args, params.Cursor)
		argIdx++
	}

	// Append sort to query
	switch params.Sort {
	case "oldest":
		query += " ORDER BY created_at ASC"
	default:
		query += " ORDER BY created_at DESC"
	}

	query += fmt.Sprintf(" LIMIT $%d", argIdx)
	args = append(args, params.Limit)

	// Fire query
	rows, err := cr.db.Query(ctx, query, args...)
	if err != nil {
		cr.logger.Error("failed to fetch all complaints from database", "error", err)
		return nil, ErrInternalError
	}
	defer rows.Close()

	// Scan rows
	var complaints []Complaint
	for rows.Next() {
		var complaint Complaint
		err := rows.Scan(
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
			cr.logger.Error("failed to scan complaint row", "error", err)
			return nil, ErrInternalError
		}

		complaints = append(complaints, complaint)
	}

	return complaints, nil
}
