package user

import (
	"context"
	"errors"
	"log/slog"

	"github.com/aprimr/reportit/internal/auth"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type UserRepository interface {
	UpdateFullnameByUid(ctx context.Context, uid, fullname string) error
	GetPasswordHash(ctx context.Context, uid string) (string, error)
	UpdatePassword(ctx context.Context, uid string, newPasswordHash string) error
	GetUserByUid(ctx context.Context, uid string) (*auth.User, error)
	GetComplaintStats(ctx context.Context, uid string) (*UserComplaintStats, error)
}

type userRepository struct {
	db     *pgxpool.Pool
	logger *slog.Logger
}

func NewUserRepository(db *pgxpool.Pool, logger *slog.Logger) UserRepository {
	return &userRepository{
		db:     db,
		logger: logger,
	}
}

// GetUserByUid fetches a user by the uid
func (ur *userRepository) GetUserByUid(ctx context.Context, uid string) (*auth.User, error) {
	var user auth.User

	query := `SELECT uid, fullname, email, phone, role, is_verified, created_at, updated_at FROM users WHERE uid=$1`

	err := ur.db.QueryRow(ctx, query, uid).Scan(
		&user.Uid,
		&user.Fullname,
		&user.Email,
		&user.Phone,
		&user.Role,
		&user.IsVerified,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, ErrUserNotFound
		}

		ur.logger.Error("database query failed", "error", err, "uid", uid)
		return nil, ErrInternalError
	}

	return &user, nil
}

// GetComplaintStatus returns the no of complaints for a status
func (ur *userRepository) GetComplaintStats(ctx context.Context, uid string) (*UserComplaintStats, error) {
	var stats UserComplaintStats

	query := `SELECT COUNT(*) FILTER (WHERE status = 'open') AS open,
        COUNT(*) FILTER (WHERE status = 'verified') AS verified,
        COUNT(*) FILTER (WHERE status = 'resolved') AS resolved,
        COUNT(*) FILTER (WHERE status = 'rejected') AS rejected,
        COUNT(*) AS total FROM complaints WHERE uid=$1`

	err := ur.db.QueryRow(ctx, query, uid).Scan(
		&stats.Open,
		&stats.Verified,
		&stats.Resolved,
		&stats.Rejected,
		&stats.Total,
	)

	return &stats, err
}

// UpdateFullnameByUid updates the fullname for the user
func (ur *userRepository) UpdateFullnameByUid(ctx context.Context, uid, fullname string) error {
	query := `UPDATE users SET fullname=$1, updated_at=NOW() WHERE uid=$2`

	cmdTag, err := ur.db.Exec(ctx, query, fullname, uid)
	if err != nil {
		ur.logger.Error("failed to update fullname", "error", err, "uid", uid)
		return ErrInternalError
	}
	if cmdTag.RowsAffected() == 0 {
		return ErrUserNotFound
	}

	return nil
}

// GetPasswordHash fetches password hash from database
func (ur *userRepository) GetPasswordHash(ctx context.Context, uid string) (string, error) {
	var passwordHash string
	query := `SELECT password_hash FROM users WHERE uid=$1`
	err := ur.db.QueryRow(ctx, query, uid).Scan(&passwordHash)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return "", ErrUserNotFound
		}

		ur.logger.Error("failed to fetch password from database", "error", err, "uid", uid)
		return "", ErrInternalError
	}
	return passwordHash, nil
}

// UpdatePassword sets new password hash in database
func (ur *userRepository) UpdatePassword(ctx context.Context, uid string, newPasswordHash string) error {
	query := `UPDATE users SET password_hash=$1 WHERE uid=$2`
	cmdTag, err := ur.db.Exec(ctx, query, newPasswordHash, uid)
	if err != nil {
		ur.logger.Error("failed to update password in databas", "error", err, "uid", uid)
		return ErrInternalError
	}
	if cmdTag.RowsAffected() == 0 {
		return ErrUserNotFound
	}

	return nil
}
