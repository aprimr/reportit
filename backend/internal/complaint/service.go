package complaint

import (
	"context"
	"log/slog"
	"mime/multipart"

	"github.com/aprimr/reportit/internal/utils"
)

type ComplaintService interface {
	UploadImage(ctx context.Context, fileHeader multipart.File) (string, error)
	DeleteImage(ctx context.Context, imageURL string) error
	CreateComplaint(ctx context.Context, uid string, complaintReq CreateComplaintRequest) (*Complaint, error)
}

type complaintService struct {
	logger        *slog.Logger
	complaintRepo ComplaintRepository
}

func NewComplaintService(logger *slog.Logger, complaintRepo ComplaintRepository) ComplaintService {
	return &complaintService{
		logger:        logger,
		complaintRepo: complaintRepo,
	}
}

// UploadImage
func (cs *complaintService) UploadImage(ctx context.Context, file multipart.File) (string, error) {
	// Call cloudinaru util
	url, err := utils.UploadImage(ctx, file)
	if err != nil {
		cs.logger.Error("failed to upload image to cloudinary", "error", err)
		return "", ErrInternalError
	}

	return url, nil
}

// DeleteImage
func (cs *complaintService) DeleteImage(ctx context.Context, imageURL string) error {
	err := utils.DeleteImage(ctx, imageURL)
	if err != nil {
		cs.logger.Error("failed to delete image from cloudinary", "error", err, "image_url", imageURL)
		return ErrInternalError
	}

	return nil
}

// CreateComplaint
func (cs *complaintService) CreateComplaint(ctx context.Context, uid string, complaintReq CreateComplaintRequest) (*Complaint, error) {
	// Call repository
	complaint, err := cs.complaintRepo.Create(ctx, uid, complaintReq)

	return complaint, err
}
