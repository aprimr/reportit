package auth

import (
	"context"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type AuthRepository interface {
	CreateUser(ctx context.Context, regReq *RegisterRequest) (*User, error)
	GetUserByEmailOrPhone(ctx context.Context, emailOrPhone string) (*User, error)
	GetUserByUid(ctx context.Context, uid string) (*User, error)
	SaveRefreshToken(ctx context.Context, uid, tokenHash string) error
	RotateRefreshToken(ctx context.Context, uid, oldTokenHash, newTokenHash string) error
	DeleteRefreshToken(ctx context.Context, refreshTokenHash string) error
	DeleteUserRefreshTokens(ctx context.Context, uid string) error
}

type authRepository struct {
	db     *pgxpool.Pool
	logger *slog.Logger
}

func NewAuthRepository(db *pgxpool.Pool, logger *slog.Logger) AuthRepository {
	return &authRepository{
		db:     db,
		logger: logger,
	}
}

// CreateUser inserts a row for user in the users table
func (ar *authRepository) CreateUser(ctx context.Context, regReq *RegisterRequest) (*User, error) {
	var user User
	query := `INSERT INTO users (fullname, email, phone, password_hash) Values($1, $2, $3, $4) RETURNING uid, fullname, email, phone, role, is_verified, created_at, updated_at`

	err := ar.db.QueryRow(ctx, query, regReq.Fullname, regReq.Email, regReq.Phone, regReq.Password).Scan(
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
		ar.logger.Error("database insert failed", "error", err, "email", regReq.Email)
		return nil, ErrInternalError
	}

	return &user, nil
}

// GetUserByEmailOrPhone fetches a user by matching email or phone in the database
func (ar *authRepository) GetUserByEmailOrPhone(ctx context.Context, emailOrPhone string) (*User, error) {
	var user User

	query := `SELECT uid, fullname, email, phone, password_hash, role, is_verified, created_at, updated_at FROM users WHERE email=$1 OR phone=$1`

	err := ar.db.QueryRow(ctx, query, emailOrPhone).Scan(
		&user.Uid,
		&user.Fullname,
		&user.Email,
		&user.Phone,
		&user.PasswordHash,
		&user.Role,
		&user.IsVerified,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}

		ar.logger.Error("database query failed", "error", err, "identifier", emailOrPhone)
		return nil, ErrInternalError
	}

	return &user, nil
}

// GetUserByUid fetches a user by the uid
func (ar *authRepository) GetUserByUid(ctx context.Context, uid string) (*User, error) {
	var user User

	query := `SELECT uid, fullname, email, phone, password_hash, role, is_verified, created_at, updated_at FROM users WHERE uid=$1`

	err := ar.db.QueryRow(ctx, query, uid).Scan(
		&user.Uid,
		&user.Fullname,
		&user.Email,
		&user.Phone,
		&user.PasswordHash,
		&user.Role,
		&user.IsVerified,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}

		ar.logger.Error("database query failed", "error", err, "uid", uid)
		return nil, ErrInternalError
	}

	return &user, nil
}

// SaveRefreshToken saves the refresh token in the database
func (ar *authRepository) SaveRefreshToken(ctx context.Context, uid, tokenHash string) error {
	query := `INSERT INTO refresh_tokens (uid, token_hash, expires_at) VALUES($1, $2, $3)`

	_, err := ar.db.Exec(ctx, query, uid, tokenHash, time.Now().Add(time.Hour*24*30))
	if err != nil {
		ar.logger.Error("failed to save refresh token in database", "error", err, "uid", uid)
		return ErrInternalError
	}

	return nil
}

// RotateRefreshToken deletes the old token from the database and stores the new token
func (ar *authRepository) RotateRefreshToken(ctx context.Context, uid, oldTokenHash, newTokenHash string) error {
	// Start db transaction
	tx, err := ar.db.Begin(ctx)
	if err != nil {
		ar.logger.Error("failed to begin transaction", "error", err, "uid", uid)
		return ErrInternalError
	}
	defer tx.Rollback(ctx)

	// Delete the old token from database
	cmdTag, err := tx.Exec(ctx, `DELETE FROM refresh_tokens WHERE token_hash=$1 AND uid=$2 AND expires_at > NOW()`, oldTokenHash, uid)
	if err != nil {
		return ErrInternalError
	}
	if cmdTag.RowsAffected() == 0 {
		ar.logger.Warn("alert: possible refresh token reuse detected", "uid", uid)

		// Delete all active refresh tokens
		_, _ = tx.Exec(ctx, `DELETE FROM refresh_tokens WHERE uid=$1`, uid)
		_ = tx.Commit(ctx)
		return ErrSessionExpired
	}

	// Insert new token in the database
	_, err = tx.Exec(ctx, `INSERT INTO refresh_tokens (uid, token_hash, expires_at) VALUES($1, $2, $3)`, uid, newTokenHash, time.Now().Add(time.Hour*24*30))
	if err != nil {
		ar.logger.Warn("failed to insert new refres token in database", "error", err, "uid", uid)
		return ErrInternalError
	}

	return tx.Commit(ctx)
}

// DeleteRefreshTokenByTokenId deletes the refresh token from the database
func (ar *authRepository) DeleteRefreshToken(ctx context.Context, refreshTokenHash string) error {
	query := `DELETE FROM refresh_tokens WHERE token_hash=$1`

	_, err := ar.db.Exec(ctx, query, refreshTokenHash)
	if err != nil {
		ar.logger.Error("failed to delete refresh token from database", "error", err)
		return ErrInternalError
	}

	return nil
}

// DeleteUserRefreshTokens deletes all the refresh token for a user from the database
func (ar *authRepository) DeleteUserRefreshTokens(ctx context.Context, uid string) error {
	query := `DELETE FROM refresh_tokens WHERE uid=$1`

	_, err := ar.db.Exec(ctx, query, uid)
	if err != nil {
		ar.logger.Error("failed to delete user's refresh tokens from database", "error", err, "uid", uid)
		return ErrInternalError
	}

	return nil
}
