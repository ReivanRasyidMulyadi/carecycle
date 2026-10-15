import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/campaign_model.dart';

/// Repository untuk mengelola fitur Open Campaign (Kampanye Terbuka)
class CampaignRepository {
  final SupabaseClient _client;

  CampaignRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService.client;

  /// Ambil daftar semua kampanye dengan opsi filter status & kategori
  Future<List<CampaignModel>> getCampaigns({
    String? status,
    String? category,
  }) async {
    var query = _client.from('campaigns').select(
          '*, communities:community_id(community_name)',
        );

    if (status != null && status != 'all') {
      query = query.eq('status', status);
    }

    if (category != null && category != 'all') {
      query = query.eq('target_category', category);
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => CampaignModel.fromJson(e)).toList();
  }

  /// Buat kampanye baru oleh Komunitas / Yayasan yang terverifikasi
  Future<CampaignModel> createCampaign({
    required String communityId,
    required String title,
    required String description,
    required String targetCategory,
    required int targetQuantity,
    DateTime? endDate,
  }) async {
    final data = await _client
        .from('campaigns')
        .insert({
          'community_id': communityId,
          'title': title.trim(),
          'description': description.trim(),
          'target_category': targetCategory,
          'target_quantity': targetQuantity,
          'collected_quantity': 0,
          if (endDate != null) 'end_date': endDate.toUtc().toIso8601String(),
          'status': 'active',
        })
        .select('*, communities:community_id(community_name)')
        .single();

    return CampaignModel.fromJson(data);
  }

  /// Dukung kampanye (Pledge donasi dari Donatur)
  Future<void> pledgeCampaign({
    required String campaignId,
    required String donorId,
    required int quantity,
    String? notes,
  }) async {
    // 1. Catat ke tabel campaign_pledges
    await _client.from('campaign_pledges').insert({
      'campaign_id': campaignId,
      'donor_id': donorId,
      'quantity': quantity,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });

    // 2. Tambah collected_quantity pada kampanye
    final current = await _client
        .from('campaigns')
        .select('collected_quantity, target_quantity')
        .eq('id', campaignId)
        .single();

    final currentQty = (current['collected_quantity'] as num?)?.toInt() ?? 0;
    final targetQty = (current['target_quantity'] as num?)?.toInt() ?? 0;
    final newQty = currentQty + quantity;

    await _client.from('campaigns').update({
      'collected_quantity': newQty,
      if (newQty >= targetQty) 'status': 'completed',
    }).eq('id', campaignId);
  }

  /// Perbarui status kampanye (Admin atau Yayasan pemilik)
  Future<CampaignModel> updateCampaignStatus({
    required String campaignId,
    required String newStatus,
  }) async {
    final data = await _client
        .from('campaigns')
        .update({'status': newStatus})
        .eq('id', campaignId)
        .select('*, communities:community_id(community_name)')
        .single();

    return CampaignModel.fromJson(data);
  }
}
