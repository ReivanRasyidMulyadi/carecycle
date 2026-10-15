/// Model Kampanye Sosial Donasi CareCycle
class CampaignModel {
  final String id;
  final String communityId;
  final String? communityName;
  final String title;
  final String description;
  final String targetCategory;
  final int targetQuantity;
  final int collectedQuantity;
  final String? bannerUrl;
  final DateTime? endDate;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CampaignModel({
    required this.id,
    required this.communityId,
    this.communityName,
    required this.title,
    required this.description,
    required this.targetCategory,
    required this.targetQuantity,
    this.collectedQuantity = 0,
    this.bannerUrl,
    this.endDate,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  double get progressPercentage {
    if (targetQuantity <= 0) return 0.0;
    final ratio = collectedQuantity / targetQuantity;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Sedang Berjalan';
      case 'completed':
        return 'Tercapai & Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get categoryDisplay {
    switch (targetCategory.toLowerCase()) {
      case 'clothing':
        return 'Pakaian';
      case 'electronics':
        return 'Elektronik';
      case 'books':
        return 'Buku & Edukasi';
      case 'furniture':
        return 'Perabotan';
      case 'toys':
        return 'Mainan Anak';
      default:
        return targetCategory;
    }
  }

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    String? commName;
    if (json['communities'] != null && json['communities'] is Map) {
      commName = json['communities']['community_name'] as String?;
    }

    return CampaignModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      communityName: commName,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetCategory: json['target_category'] as String? ?? 'clothing',
      targetQuantity: (json['target_quantity'] as num?)?.toInt() ?? 10,
      collectedQuantity: (json['collected_quantity'] as num?)?.toInt() ?? 0,
      bannerUrl: json['banner_url'] as String?,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())?.toLocal()
          : null,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'community_id': communityId,
      'title': title,
      'description': description,
      'target_category': targetCategory,
      'target_quantity': targetQuantity,
      'collected_quantity': collectedQuantity,
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (endDate != null) 'end_date': endDate!.toUtc().toIso8601String(),
      'status': status,
    };
  }
}
