import 'package:app/core/model/complaint_model.dart';
import 'package:app/core/services/complaint_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final complaintServiceProvider = Provider<ComplaintService>(
  (ref) => ComplaintService(),
);

final complaintProvider =
    StateNotifierProvider<ComplaintNotifier, List<ComplaintModel>>((ref) {
      return ComplaintNotifier(ref, ref.watch(complaintServiceProvider));
    });

final feedComplaintProvider =
    StateNotifierProvider<FeedComplaintNotifier, List<FeedComplaintModel>>((
      ref,
    ) {
      return FeedComplaintNotifier(ref.watch(complaintServiceProvider));
    });

class ComplaintNotifier extends StateNotifier<List<ComplaintModel>> {
  final Ref _ref;
  final ComplaintService _complaintService;

  ComplaintNotifier(this._ref, this._complaintService) : super([]);

  Future<void> createComplaint({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required bool isPublic,
    required List<XFile?> images,
  }) async {
    try {
      final response = await _complaintService.createComplaint(
        title: title,
        description: description,
        category: category,
        latitude: latitude,
        longitude: longitude,
        isPublic: isPublic,
        images: images,
      );
      state = [response.data, ...state];

      await _ref.read(feedComplaintProvider.notifier).fetchAllComplaints();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchMyComplaints({
    String? search,
    String? status,
    String? sort,
    int? limit,
  }) async {
    try {
      final response = await _complaintService.getMyComplaints(
        search: search,
        status: status,
        sort: sort,
        limit: limit,
      );
      state = response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComplaint(String id) async {
    try {
      await _complaintService.deleteComplaint(id: id);
      state = state.where((complaint) => complaint.id != id).toList();

      // Also remove from feed complaints state
      final feedNotifier = _ref.read(feedComplaintProvider.notifier);
      feedNotifier.removeComplaint(id);
    } catch (e) {
      rethrow;
    }
  }

  void clearComplaints() {
    state = [];
  }
}

// Feed complaint provider
class FeedComplaintNotifier extends StateNotifier<List<FeedComplaintModel>> {
  final ComplaintService _complaintService;

  FeedComplaintNotifier(this._complaintService) : super([]);

  Future<void> fetchAllComplaints({
    String? search,
    String? status,
    String? sort,
    int? limit,
  }) async {
    try {
      final response = await _complaintService.getAllComplaints(
        search: search,
        status: status,
        sort: sort,
        limit: limit,
      );
      state = response.data;
    } catch (e) {
      rethrow;
    }
  }

  void addComplaint(FeedComplaintModel complaint) {
    state = [complaint, ...state];
  }

  void removeComplaint(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}
