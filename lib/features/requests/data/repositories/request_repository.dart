import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/request_model.dart';

/// Repository untuk mengelola permohonan donasi dari Komunitas,
/// persetujuan/penolakan oleh Donatur, dan penentuan metode serah terima.
class RequestRepository {
  final SupabaseClient _client;

  RequestRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService.client;

  /// Ajukan permintaan donasi oleh Komunitas verified
  Future<RequestModel> createRequest({
    required String itemId,
    required String communityId,
    required String reason,
    String? deliveryMethod,
    String? notes,
  }) async {
    final data = await _client
        .from('requests')
        .insert({
          'item_id': itemId,
          'community_id': communityId,
          'reason': reason.trim(),
          'status': 'submitted',
          if (deliveryMethod != null) 'delivery_method': deliveryMethod,
          if (notes != null) 'notes': notes.trim(),
        })
        .select(
          '*, communities:community_id(community_name, verification_status, description), items:item_id(name, category, photo_urls, donor_id)',
        )
        .single();

    // Perbarui status item menjadi 'requested'
    try {
      await _client
          .from('items')
          .update({'status': 'requested'})
          .eq('id', itemId);
    } catch (_) {}

    return RequestModel.fromJson(data);
  }

  /// Ambil daftar permintaan masuk untuk barang-barang milik donatur tertentu
  Future<List<RequestModel>> getIncomingRequestsForDonor(String donorId) async {
    final data = await _client
        .from('requests')
        .select(
          '*, communities:community_id(community_name, verification_status, description), items:item_id!inner(name, category, photo_urls, donor_id)',
        )
        .eq('items.donor_id', donorId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => RequestModel.fromJson(e)).toList();
  }

  /// Ambil daftar permintaan yang diajukan oleh komunitas tertentu
  Future<List<RequestModel>> getMyCommunityRequests(String communityId) async {
    final data = await _client
        .from('requests')
        .select(
          '*, communities:community_id(community_name, verification_status, description), items:item_id(name, category, photo_urls, donor_id)',
        )
        .eq('community_id', communityId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => RequestModel.fromJson(e)).toList();
  }

  /// Setujui permintaan donasi oleh Donatur:
  /// - Status request menjadi 'approved'
  /// - Status item menjadi 'processing' (in-process) secara realtime
  /// - Menentukan metode serah terima
  Future<RequestModel> approveRequest({
    required String requestId,
    required String itemId,
    String? deliveryMethod,
    String? trackingNumber,
    String? notes,
  }) async {
    // 1. Update status request
    final reqData = await _client
        .from('requests')
        .update({
          'status': 'approved',
          if (deliveryMethod != null) 'delivery_method': deliveryMethod,
          if (trackingNumber != null) 'tracking_number': trackingNumber.trim(),
          if (notes != null) 'notes': notes.trim(),
        })
        .eq('id', requestId)
        .select(
          '*, communities:community_id(community_name, verification_status, description), items:item_id(name, category, photo_urls, donor_id)',
        )
        .single();

    // 2. Update status item menjadi 'processing' (in-process)
    await _client
        .from('items')
        .update({
          'status': 'processing',
          'accepted_request_id': requestId,
        })
        .eq('id', itemId);

    return RequestModel.fromJson(reqData);
  }

  /// Tolak permintaan donasi oleh Donatur
  Future<RequestModel> rejectRequest({
    required String requestId,
    required String itemId,
    String? notes,
  }) async {
    final reqData = await _client
        .from('requests')
        .update({
          'status': 'rejected',
          if (notes != null) 'notes': notes.trim(),
        })
        .eq('id', requestId)
        .select(
          '*, communities:community_id(community_name, verification_status, description), items:item_id(name, category, photo_urls, donor_id)',
        )
        .single();

    // Cek apakah masih ada permintaan pending lain untuk barang ini
    final remaining = await _client
        .from('requests')
        .select('id')
        .eq('item_id', itemId)
        .eq('status', 'submitted');

    if ((remaining as List).isEmpty) {
      await _client
          .from('items')
          .update({'status': 'available'})
          .eq('id', itemId);
    }

    return RequestModel.fromJson(reqData);
  }

  /// Perbarui metode serah terima dan informasi resi / koordinasi
  Future<RequestModel> updateDeliveryDetails({
    required String requestId,
    required String deliveryMethod,
    String? trackingNumber,
    String? notes,
  }) async {
    final data = await _client
        .from('requests')
        .update({
          'delivery_method': deliveryMethod,
          if (trackingNumber != null) 'tracking_number': trackingNumber.trim(),
          if (notes != null) 'notes': notes.trim(),
        })
        .eq('id', requestId)
        .select(
          '*, communities:community_id(community_name, verification_status, description), items:item_id(name, category, photo_urls, donor_id)',
        )
        .single();

    return RequestModel.fromJson(data);
  }

  /// Stream realtime untuk memantau permintaan masuk donatur
  Stream<List<Map<String, dynamic>>> streamRequestsTable() {
    return _client.from('requests').stream(primaryKey: ['id']);
  }
}
