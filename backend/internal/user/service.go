package user

import (
	"context"
	"log/slog"

	"github.com/aprimr/reportit/internal/auth"
	"github.com/aprimr/reportit/internal/utils"
)

type UserService interface {
	FetchProfile(ctx context.Context, uid string) (*auth.User, *UserComplaintStats, error)
	UpdateFullname(ctx context.Context, uid, fullname string) error
	ChangePassword(ctx context.Context, uid, currentPassword, newPassword string) error
}

type userService struct {
	userRepo UserRepository
	logger   *slog.Logger
}

func NewUserService(userRepo UserRepository, logger *slog.Logger) UserService {
	return &userService{
		userRepo: userRepo,
		logger:   logger,
	}
}

func (us *userService) FetchProfile(ctx context.Context, uid string) (*auth.User, *UserComplaintStats, error) {
	// Call repository
	user, err := us.userRepo.GetUserByUid(ctx, uid)
	if err != nil {
		us.logger.Error("failed to fetch user", "error", err, "uid", uid)
		return nil, nil, err
	}
	if user == nil {
		return nil, nil, err
	}

	// Fetch complaint stats
	stats, err := us.userRepo.GetComplaintStats(ctx, uid)
	if err != nil {
		us.logger.Error("failed to fetch complaint stats", "error", err, "uid", uid)
		return nil, nil, err
	}

	return user, stats, nil
}

func (us *userService) UpdateFullname(ctx context.Context, uid, fullname string) error {
	// Call repository
	err := us.userRepo.UpdateFullnameByUid(ctx, uid, fullname)
	if err != nil {
		return err
	}

	return nil
}

func (us *userService) ChangePassword(ctx context.Context, uid, currentPassword, newPassword string) error {
	// Fetch user password hash
	storedHash, err := us.userRepo.GetPasswordHash(ctx, uid)
	if err != nil {
		return err
	}

	// Check if password is correct
	match := utils.CheckPassword(currentPassword, storedHash)
	if !match {
		return ErrInvalidPassword
	}

	// Hash the new password
	newHash, err := utils.HashPassword(newPassword)
	if err != nil {
		us.logger.Error("failed to hash new password", "error", err, "uid", uid)
		return ErrInternalError
	}

	// Call repository
	err = us.userRepo.UpdatePassword(ctx, uid, string(newHash))
	if err != nil {
		us.logger.Error("failed to save new passwordhash", "error", err, "uid", uid)
		return err
	}

	return nil
}
