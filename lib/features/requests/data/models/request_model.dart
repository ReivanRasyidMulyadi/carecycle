/// Model data permohonan permintaan barang oleh Komunitas
class RequestModel {
  final String id;
  final String itemId;
  final String communityId;
  final String reason;
  final String status; // 'submitted', 'approved', 'rejected', 'received'
  final String? deliveryMethod; // 'courier', 'self_deliver', 'pickup'
  final String? trackingNumber;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Metadata relasi untuk tampilan UI
  final String? communityName;
  final bool? isCommunityVerified;
  final String? communityDescription;
  final String? itemName;
  final String? itemPhotoUrl;
  final String? itemCategory;
  final String? donorId;

  const RequestModel({
    required this.id,
    required this.itemId,
    required this.communityId,
    required this.reason,
    this.status = 'submitted',
    this.deliveryMethod,
    this.trackingNumber,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.communityName,
    this.isCommunityVerified,
    this.communityDescription,
    this.itemName,
    this.itemPhotoUrl,
    this.itemCategory,
    this.donorId,
  });

  bool get isSubmitted => status == 'submitted';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isReceived => status == 'received';

  String get statusDisplay {
    switch (status) {
      case 'submitted':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui (Sedang Diproses)';
      case 'rejected':
        return 'Ditolak';
      case 'received':
        return 'Barang Diterima';
      default:
        return status;
    }
  }

  String get deliveryMethodDisplay {
    switch (deliveryMethod) {
      case 'courier':
        return 'Kurir / Ekspedisi';
      case 'self_deliver':
        return 'Diantar Langsung oleh Donatur';
      case 'pickup':
        return 'Dijemput oleh Komunitas';
      default:
        return 'Belum Ditentukan';
    }
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    String? cName;
    bool? cVerified;
    String? cDesc;
    if (json['communities'] != null && json['communities'] is Map) {
      final c = json['communities'] as Map;
      cName = c['community_name'] as String?;
      cVerified = c['verification_status'] == 'verified';
      cDesc = c['description'] as String?;
    }

    String? iName;
    String? iPhoto;
    String? iCat;
    String? dId;
    if (json['items'] != null && json['items'] is Map) {
      final i = json['items'] as Map;
      iName = i['name'] as String?;
      iCat = i['category'] as String?;
      dId = i['donor_id'] as String?;
      if (i['photo_urls'] != null && i['photo_urls'] is List && (i['photo_urls'] as List).isNotEmpty) {
        iPhoto = (i['photo_urls'] as List).first as String?;
      }
    }

    return RequestModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      communityId: json['community_id'] as String,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'submitted',
      deliveryMethod: json['delivery_method'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      communityName: cName ?? json['community_name'] as String?,
      isCommunityVerified: cVerified ?? (json['is_community_verified'] as bool?),
      communityDescription: cDesc ?? json['community_description'] as String?,
      itemName: iName ?? json['item_name'] as String?,
      itemPhotoUrl: iPhoto ?? json['item_photo_url'] as String?,
      itemCategory: iCat ?? json['item_category'] as String?,
      donorId: dId ?? json['donor_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'community_id': communityId,
      'reason': reason,
      'status': status,
      if (deliveryMethod != null) 'delivery_method': deliveryMethod,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  RequestModel copyWith({
    String? id,
    String? itemId,
    String? communityId,
    String? reason,
    String? status,
    String? deliveryMethod,
    String? trackingNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? communityName,
    bool? isCommunityVerified,
    String? communityDescription,
    String? itemName,
    String? itemPhotoUrl,
    String? itemCategory,
    String? donorId,
  }) {
    return RequestModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      communityId: communityId ?? this.communityId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      communityName: communityName ?? this.communityName,
      isCommunityVerified: isCommunityVerified ?? this.isCommunityVerified,
      communityDescription: communityDescription ?? this.communityDescription,
      itemName: itemName ?? this.itemName,
      itemPhotoUrl: itemPhotoUrl ?? this.itemPhotoUrl,
      itemCategory: itemCategory ?? this.itemCategory,
      donorId: donorId ?? this.donorId,
    );
  }
}
