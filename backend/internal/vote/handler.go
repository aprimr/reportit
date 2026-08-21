package vote

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/aprimr/reportit/internal/middlewares"
	"github.com/aprimr/reportit/internal/utils"
	"github.com/go-chi/chi/v5"
)

type VoteHandler interface {
	Vote(w http.ResponseWriter, r *http.Request)
	GetVotes(w http.ResponseWriter, r *http.Request)
}

type voteHandler struct {
	voteService VoteService
}

func NewVoteHandler(voteService VoteService) VoteHandler {
	return &voteHandler{
		voteService: voteService,
	}
}

// Get votes for a complaint
func (vh *voteHandler) GetVotes(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	// Get complaint id from url params
	complaintID := chi.URLParam(r, "id")
	if strings.TrimSpace(complaintID) == "" {
		utils.WriteError(w, http.StatusBadRequest, "missing complaint id")
		return
	}

	// Call service
	votes, err := vh.voteService.GetVotes(r.Context(), uid, complaintID)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		return
	}

	utils.WriteJSON(w, http.StatusOK, votes, "votes fetch successful")
}

// Create, update, or remove a vote
func (vh *voteHandler) Vote(w http.ResponseWriter, r *http.Request) {
	// Get uid from request context
	uid := middlewares.GetUidFromContext(r.Context())
	if uid == "" {
		utils.WriteError(w, http.StatusUnauthorized, ErrUnauthorized.Error())
		return
	}

	// Parse request body
	var voteReq VoteRequest
	if err := json.NewDecoder(r.Body).Decode(&voteReq); err != nil {
		utils.WriteError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Validate complaint id
	if voteReq.ComplaintID.String() == "" {
		utils.WriteError(w, http.StatusBadRequest, "complaint id is required")
		return
	}

	// Call service
	vote, err := vh.voteService.Vote(r.Context(), uid, &voteReq)
	if err != nil {
		switch {
		case errors.Is(err, ErrVoteFailed):
			utils.WriteError(w, http.StatusInternalServerError, ErrVoteFailed.Error())
		case errors.Is(err, ErrUnvoteFailed):
			utils.WriteError(w, http.StatusInternalServerError, ErrUnvoteFailed.Error())
		case errors.Is(err, ErrVoteNotFound):
			utils.WriteError(w, http.StatusNotFound, ErrVoteNotFound.Error())
		default:
			utils.WriteError(w, http.StatusInternalServerError, ErrInternalError.Error())
		}
		return
	}

	utils.WriteJSON(w, http.StatusOK, vote, "vote successful")
}
