package auth

import (
	"context"
	"log/slog"

	"github.com/aprimr/reportit/internal/utils"
)

type AuthService interface {
	Register(ctx context.Context, regReq RegisterRequest) (*User, error)
	Login(ctx context.Context, loginReq LoginRequest) (string, string, error)
	Logout(ctx context.Context, refreshToken string) error
	LogoutFromAllDevice(ctx context.Context, Uid string) error
	RefreshToken(ctx context.Context, refreshToken string) (string, string, error)
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
	if user == nil {
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

// Logout deletes the refresh token for the current device
func (as *authService) Logout(ctx context.Context, refreshToken string) error {
	// Hash refresh token
	refreshTokenHash, err := utils.HashString(refreshToken)
	if err != nil {
		as.logger.Error("failed to hash refresh token", "error", err)
		return ErrInternalError
	}

	// Call repository
	err = as.authRepo.DeleteRefreshToken(ctx, refreshTokenHash)
	if err != nil {
		as.logger.Error("failed to delete refresh token", "error", err)
		return err
	}
	return nil
}

// LogoutFromAllDevice deletes all the refresh token for the user
func (as *authService) LogoutFromAllDevice(ctx context.Context, uid string) error {
	// Call repository
	err := as.authRepo.DeleteUserRefreshTokens(ctx, uid)
	if err != nil {
		as.logger.Error("failed to delete user's all refresh tokens", "error", err)
		return err
	}

	return nil
}

// RefreshToken validates the refresh token and extracts the uid from the token
func (as *authService) RefreshToken(ctx context.Context, refreshToken string) (string, string, error) {
	// Validate refresh token
	claims, err := utils.ValidateToken(refreshToken, true)
	if err != nil {
		as.logger.Error("failed to validate refresh token", "error", err)
		return "", "", ErrTokenInvalid
	}

	// Extract uid from refresh token claims
	uid, ok := claims["uid"].(string)
	if !ok {
		return "", "", ErrTokenInvalid
	}

	// Hash old refresh token for comparing it with the token stored in database
	oldTokenHash, err := utils.HashString(refreshToken)
	if err != nil {
		as.logger.Error("failed to hash refresh token", "error", err, "uid", uid)
		return "", "", ErrInternalError
	}

	// Get user details
	user, err := as.authRepo.GetUserByUid(ctx, uid)
	if err != nil {
		return "", "", err
	}

	// Generate new access token
	newAccessToken, err := utils.GenerateAccessToken(uid, user.Email, user.Phone, user.Role)
	if err != nil {
		as.logger.Error("failed to generate access token", "error", err, "uid", uid)
		return "", "", ErrInternalError
	}

	// Generate a new refresh token and hash it
	newRefreshToken, err := utils.GenerateRefreshToken(uid)
	if err != nil {
		as.logger.Error("failed to generate new refresh token", "error", err, "uid", uid)
		return "", "", ErrInternalError
	}
	newHashedRefreshToken, err := utils.HashString(newRefreshToken)
	if err != nil {
		as.logger.Error("failed to hash new refresh token", "error", err, "uid", uid)
		return "", "", ErrInternalError
	}

	// Call repository
	err = as.authRepo.RotateRefreshToken(ctx, uid, oldTokenHash, newHashedRefreshToken)
	if err != nil {
		as.logger.Error("failed to rotate access token", "error", err, "uid", uid)
		return "", "", ErrInternalError
	}

	return newAccessToken, newRefreshToken, nil
}
