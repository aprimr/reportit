class VoteModel {
  final int upvotes;
  final int downvotes;
  final bool? userVote;

  VoteModel({required this.upvotes, required this.downvotes, this.userVote});

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      userVote: json['user_vote'],
    );
  }
}

class VoteRequest {
  final String complaintId;
  final bool isUpvote;

  VoteRequest({required this.complaintId, required this.isUpvote});

  Map<String, dynamic> toJson() {
    return {'complaint_id': complaintId, 'is_upvote': isUpvote};
  }
}

class VoteResponse {
  final bool success;
  final String message;
  final VoteModel data;

  VoteResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    return VoteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: VoteModel.fromJson(json['data'] ?? {}),
    );
  }
}
