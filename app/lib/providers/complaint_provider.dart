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
      return FeedComplaintNotifier(ref.watch(complaintServiceProvider), ref);
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

  Future<void> toggleComplaintVisibility(String id) async {
    try {
      await _complaintService.toggleComplaintVisibility(id: id);

      // Update the isPublic state of the complaint
      state = state.map((c) {
        if (c.id == id) {
          return ComplaintModel(
            id: c.id,
            uid: c.uid,
            title: c.title,
            description: c.description,
            category: c.category,
            imageUrls: c.imageUrls,
            latitude: c.latitude,
            longitude: c.longitude,
            isPublic: !c.isPublic, // Update state
            status: c.status,
            adminRemarks: c.adminRemarks,
            verifiedAt: c.verifiedAt,
            rejectedAt: c.rejectedAt,
            resolvedAt: c.resolvedAt,
            createdAt: c.createdAt,
          );
        }
        return c;
      }).toList();

      // Remove complaint from feed complaints state
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
final isFetchingMoreProvider = StateProvider<bool>((ref) => false);

class FeedComplaintNotifier extends StateNotifier<List<FeedComplaintModel>> {
  final ComplaintService _complaintService;
  final Ref _ref;

  FeedComplaintNotifier(this._complaintService, this._ref) : super([]);

  String? _nextCursor;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  Future<void> fetchAllComplaints({
    String? search,
    String? status,
    String? sort,
    int? limit,
  }) async {
    // reset states
    _nextCursor = null;
    _hasMore = true;

    try {
      final response = await _complaintService.getAllComplaints(
        search: search,
        status: status,
        sort: sort,
        limit: limit,
      );
      state = response.data;

      if (response.data.isNotEmpty) {
        _nextCursor = response.data.last.createdAt;
      }

      if (response.data.length < (limit ?? 10)) {
        _hasMore = false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchMoreFeedComplaints({
    String? search,
    String? status,
    String? sort,
    int? limit,
  }) async {
    if (!_hasMore || _ref.read(isFetchingMoreProvider)) return;
    _ref.read(isFetchingMoreProvider.notifier).state = true;

    try {
      final response = await _complaintService.getAllComplaints(
        search: search,
        status: status,
        sort: sort,
        limit: limit,
        cursor: _nextCursor,
      );

      final newItems = response.data;
      if (newItems.isNotEmpty) {
        state = [...state, ...newItems];
        _nextCursor = newItems.last.createdAt;
      }

      if (newItems.length < (limit ?? 10)) {
        _hasMore = false;
      }
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(isFetchingMoreProvider.notifier).state = false;
    }
  }

  void addComplaint(FeedComplaintModel complaint) {
    state = [complaint, ...state];
  }

  void removeComplaint(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}
