package auth

import (
	"context"
	"log/slog"

	"github.com/aprimr/ccms/internal/utils"
)

type AuthService interface {
	Register(ctx context.Context, regReq RegisterRequest) (*User, error)
	Login(ctx context.Context, loginReq LoginRequest) (string, string, error)
}

type authService struct {
	authRepo AuthRepository
	logger   *slog.Logger
}

func NewAuthService(authRepo AuthRepository, logger *slog.Logger) AuthService {
	return &authService{
		authRepo: authRepo,
		logger:   logger,
	}
}

// Register handles password hashing and user creation
func (as *authService) Register(ctx context.Context, regReq RegisterRequest) (*User, error) {
	// Check if email or phone already taken
	exists, err := as.authRepo.GetUserByEmailOrPhone(ctx, regReq.Email)
	if err != nil {
		return nil, ErrInternalError
	}
	if exists != nil {
		return nil, ErrEmailOrPhoneTaken
	}
	exists, err = as.authRepo.GetUserByEmailOrPhone(ctx, regReq.Phone)
	if err != nil {
		return nil, ErrInternalError
	}
	if exists != nil {
		return nil, ErrEmailOrPhoneTaken
	}

	// hash password
	hashedPassword, err := utils.HashPassword(regReq.Password)
	if err != nil {
		as.logger.Error("failed to hash password", "error", err, "email", regReq.Email)
		return nil, ErrInternalError
	}
	regReq.Password = hashedPassword

	// call repository to create user
	user, err := as.authRepo.CreateUser(ctx, &regReq)
	if err != nil {
		return nil, err
	}

	return user, nil
}

// Login validates the password and returns the access and refresh token
func (as *authService) Login(ctx context.Context, loginReq LoginRequest) (string, string, error) {
	user, err := as.authRepo.GetUserByEmailOrPhone(ctx, loginReq.EmailOrPhone)
	if err != nil {
		return "", "", ErrInvalidCreds
	}

	// compare password with hash password from database
	match := utils.CheckPassword(loginReq.Password, user.PasswordHash)
	if !match {
		return "", "", ErrInvalidCreds
	}

	// generate access token
	accessToken, err := utils.GenerateAccessToken(user.Uid.String(), user.Email, user.Phone, user.Role)
	if err != nil {
		as.logger.Error("failed to generate access token", "error", err, "uid", user.Uid)
		return "", "", ErrInternalError
	}

	// generate refresh token
	refreshToken, err := utils.GenerateRefreshToken(user.Uid.String())
	if err != nil {
		as.logger.Error("failed to generate refresh token", "error", err, "uid", user.Uid)
		return "", "", ErrInternalError
	}

	// hash refresh token
	refreshTokenHash, err := utils.HashString(refreshToken)
	if err != nil {
		as.logger.Error("failed to hash refresh token", "error", err, "uid", user.Uid)
		return "", "", ErrInternalError
	}

	// save refresh token in database
	err = as.authRepo.SaveRefreshToken(ctx, user.Uid.String(), refreshTokenHash)
	if err != nil {
		as.logger.Error("failed to store refresh token", "error", err, "uid", user.Uid)
		return "", "", ErrInternalError
	}

	return accessToken, refreshToken, nil
}
