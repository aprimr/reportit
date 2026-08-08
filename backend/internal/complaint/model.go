package complaint

import (
	"time"

	"github.com/google/uuid"
)

type Complaint struct {
	Id          uuid.UUID `json:"id"`
	Uid         uuid.UUID `json:"uid"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Category    string    `json:"category"`
	ImageUrls   []string  `json:"image_urls"`

	Longitude float64 `json:"longitude"`
	Latitude  float64 `json:"latitude"`

	IsPublic     bool    `json:"is_public"`
	Status       string  `json:"status"`
	AdminRemarks *string `json:"admin_remarks"`

	VerifiedAt *time.Time `json:"verified_at"`
	RejectedAt *time.Time `json:"rejected_at"`
	ResolvedAt *time.Time `json:"resolved_at"`
	CreatedAt  time.Time  `json:"created_at"`
}

type CreateComplaintRequest struct {
	Title       string   `json:"title"`
	Description string   `json:"description"`
	Category    string   `json:"category"`
	ImageUrls   []string `json:"image_urls"`

	Longitude float64 `json:"longitude"`
	Latitude  float64 `json:"latitude"`

	IsPublic bool `json:"is_public"`
}

type DeleteComplaintRequest struct {
	Id string `json:"id"`
}

type ComplaintFetchParams struct {
	Uid     string
	Search  string
	Status  string
	Sort    string
	Limit   int
	Cursor  string
	IsAdmin bool
}
