package complaint

import (
	"context"
	"log/slog"

	"github.com/aprimr/reportit/internal/utils"
)

type ComplaintService interface {
	CreateComplaint(ctx context.Context, uid string, complaintReq CreateComplaintRequest) (*Complaint, error)
	DeleteComplaint(ctx context.Context, id string) error
	GetComplaint(ctx context.Context, id string) (*Complaint, error)
	GetMyComplaints(ctx context.Context, params ComplaintFetchParams) ([]Complaint, error)
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

func (cs *complaintService) CreateComplaint(ctx context.Context, uid string, complaintReq CreateComplaintRequest) (*Complaint, error) {
	// Call repository
	complaint, err := cs.complaintRepo.Create(ctx, uid, complaintReq)

	return complaint, err
}

func (cs *complaintService) DeleteComplaint(ctx context.Context, id string) error {
	// Fetch complaint from its id
	complaint, err := cs.complaintRepo.FetchById(ctx, id)
	if err != nil {
		cs.logger.Error("failed to fetch complaint", "error", err)
		return err
	}

	// Call repository to delete complaint
	err = cs.complaintRepo.Delete(ctx, id)
	if err != nil {
		cs.logger.Error("failed to delete complaint", "error", err)
		return err
	}

	// Delete images from cloudinary in background
	go func() {
		bgCtx := context.Background()
		// Loop through image URLs and delete them from Cloudinary
		for _, imgURL := range complaint.ImageUrls {
			if imgURL != "" {
				err := utils.DeleteImage(bgCtx, imgURL)
				if err != nil {
					cs.logger.Error("failed to delete image from cloudinary during complaint deletion", "error", err, "image_url", imgURL)
				}
			}
		}
	}()

	return nil
}

func (cs *complaintService) GetComplaint(ctx context.Context, id string) (*Complaint, error) {
	// Call repository
	complaint, err := cs.complaintRepo.FetchById(ctx, id)
	if err != nil {
		cs.logger.Error("failed to fetch complaint", "error", err)
		return nil, err
	}

	return complaint, nil
}

func (cs *complaintService) GetMyComplaints(ctx context.Context, params ComplaintFetchParams) ([]Complaint, error) {
	// Call repository
	complaint, err := cs.complaintRepo.FetchUserComplaints(ctx, params)
	if err != nil {
		cs.logger.Error("failed to get user complaints", "error", err, "uid", params.Uid)
		return nil, err
	}

	return complaint, nil
}
