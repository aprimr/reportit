package complaint

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/aprimr/reportit/internal/middlewares"
	"github.com/aprimr/reportit/internal/utils"
	"github.com/go-chi/chi/v5"
)

type ComplaintHandler interface {
	CreateComplaint(w http.ResponseWriter, r *http.Request)
	DeleteComplaint(w http.ResponseWriter, r *http.Request)
	GetComplaint(w http.ResponseWriter, r *http.Request)
	GetMyComplaints(w http.ResponseWriter, r *http.Request)
}

type complaintHandler struct {
	complaintService ComplaintService
}

func NewComplaintHandler(complaintService ComplaintService) ComplaintHandler {
	return &complaintHandler{
		complaintService: complaintService,
	}
}

// Create Complaint handler
func (ch *complaintHandler) CreateComplaint(w http.ResponseWriter, r *http.Request) {
	// Get uid from request header
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	// Parse multipart form
	err := r.ParseMultipartForm(10 << 20)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "failed to parse multipart form")
		return
	}

	title := strings.TrimSpace(r.FormValue("title"))
	description := strings.TrimSpace(r.FormValue("description"))
	category := strings.TrimSpace(r.FormValue("category"))
	isPublic := r.FormValue("is_public") == "true"

	latitude, err := strconv.ParseFloat(r.FormValue("latitude"), 64)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "invalid latitude coordinate")
		return
	}

	longitude, err := strconv.ParseFloat(r.FormValue("longitude"), 64)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, "invalid longitude coordinate")
		return
	}

	// Validate data
	if len(title) < 15 || len(title) > 60 {
		utils.WriteError(w, http.StatusBadRequest, "title must be between 15 and 60 characters")
		return
	}

	if len(description) < 200 || len(description) > 2500 {
		utils.WriteError(w, http.StatusBadRequest, "description must be between 200 and 2500 characters")
		return
	}

	if strings.TrimSpace(category) == "" {
		utils.WriteError(w, http.StatusBadRequest, "category is required")
		return
	}

	if latitude < -90 || latitude > 90 {
		utils.WriteError(w, http.StatusBadRequest, "invalid latitude coordinate")
		return
	}

	if longitude < -180 || longitude > 180 {
		utils.WriteError(w, http.StatusBadRequest, "invalid longitude coordinate")
		return
	}

	// get images frim form data
	files := r.MultipartForm.File["images"]
	if len(files) == 0 {
		utils.WriteError(w, http.StatusBadRequest, "image is required")
		return
	}
	if len(files) > 4 {
		utils.WriteError(w, http.StatusBadRequest, "max 4 images are allowed")
		return
	}

	// Get imageurl for each images
	var imageUrls []string
	for _, fileHeader := range files {
		// Open FileHeader and get file
		file, err := fileHeader.Open()
		if err != nil {
			utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
			return
		}
		defer file.Close()

		// Call cloudinaru util
		url, err := utils.UploadImage(r.Context(), file)
		if err != nil {
			utils.WriteError(w, http.StatusInternalServerError, "failed to upload images")
			return
		}

		imageUrls = append(imageUrls, url)
	}

	// Build request data
	newComplaintReq := CreateComplaintRequest{
		Title:       title,
		Description: description,
		Category:    category,
		ImageUrls:   imageUrls,
		Latitude:    latitude,
		Longitude:   longitude,
		IsPublic:    isPublic,
	}

	// Call CreateComplaint service
	complaint, err := ch.complaintService.CreateComplaint(r.Context(), uid, newComplaintReq)
	if err != nil {
		if errors.Is(err, ErrComplaintCreateFailed) {
			utils.WriteError(w, http.StatusInternalServerError, ErrComplaintCreateFailed.Error())
			return
		}
		utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		return
	}

	utils.WriteJSON(w, http.StatusCreated, complaint, "complaint create successful")
}

// Delete a complaint
func (ch *complaintHandler) DeleteComplaint(w http.ResponseWriter, r *http.Request) {
	// Get id from url params
	id := chi.URLParam(r, "id")
	if strings.TrimSpace(id) == "" {
		utils.WriteError(w, http.StatusBadRequest, "missing complaint id")
		return
	}

	// Call service layer
	err := ch.complaintService.DeleteComplaint(r.Context(), id)
	if err != nil {
		if errors.Is(err, ErrComplaintDeleteFailed) {
			utils.WriteError(w, http.StatusNotFound, ErrComplaintNotFound.Error())
			return
		}
		utils.WriteError(w, http.StatusInternalServerError, ErrComplaintDeleteFailed.Error())
		return
	}

	utils.WriteJSON(w, http.StatusOK, nil, "complaint delete successful")
}

// Get a complaint by its id
func (ch *complaintHandler) GetComplaint(w http.ResponseWriter, r *http.Request) {
	// Get id from url params
	id := chi.URLParam(r, "id")
	if strings.TrimSpace(id) == "" {
		utils.WriteError(w, http.StatusBadRequest, "missing complaint id")
		return
	}

	// Call service
	complaint, err := ch.complaintService.GetComplaint(r.Context(), id)
	if err != nil {
		if errors.Is(err, ErrComplaintNotFound) {
			utils.WriteError(w, http.StatusNotFound, ErrComplaintNotFound.Error())
			return
		}
		utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		return
	}

	utils.WriteJSON(w, http.StatusOK, complaint, "complaint fetch successful")
}

// Get user's complaints
func (ch *complaintHandler) GetMyComplaints(w http.ResponseWriter, r *http.Request) {
	// Get uid from request header
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	queryVals := r.URL.Query()

	// parse query params
	limit := 10
	lim, err := strconv.Atoi(queryVals.Get("limit"))
	if err == nil && lim > 0 {
		if lim > 50 {
			lim = 50
		}
		limit = lim
	}

	params := ComplaintFetchParams{
		Uid:    uid,
		Search: queryVals.Get("search"),
		Status: queryVals.Get("status"),
		Sort:   queryVals.Get("sort"),
		Limit:  limit,
		Cursor: queryVals.Get("cursor"),
	}

	// Call service layer
	complaints, err := ch.complaintService.GetMyComplaints(r.Context(), params)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		return
	}
	if complaints == nil {
		complaints = []Complaint{}
	}

	utils.WriteJSON(w, http.StatusOK, complaints, "complaints fetch successful")
}
