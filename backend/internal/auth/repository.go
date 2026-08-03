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
	SaveRefreshToken(ctx context.Context, uid, tokenHash string) error
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
