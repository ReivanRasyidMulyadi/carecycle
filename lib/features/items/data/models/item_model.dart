/// Model data barang donasi CareCycle
class ItemModel {
  final String id;
  final String donorId;
  final String name;
  final String description;
  final String category;
  final String condition;
  final List<String> photoUrls;
  final String location;
  final String status; // 'available', 'requested', 'processing', 'completed', 'pending_sync'
  final String? acceptedRequestId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Metadata offline draft Hive
  final bool isDraft;
  final String? localPhotoPath;
  final String? syncError;

  const ItemModel({
    required this.id,
    required this.donorId,
    required this.name,
    required this.description,
    required this.category,
    required this.condition,
    this.photoUrls = const [],
    required this.location,
    this.status = 'available',
    this.acceptedRequestId,
    this.createdAt,
    this.updatedAt,
    this.isDraft = false,
    this.localPhotoPath,
    this.syncError,
  });

  bool get isPendingSync => isDraft || status == 'pending_sync';
  bool get isAvailable => status == 'available';
  bool get isRequested => status == 'requested';
  bool get isInProcess => status == 'processing' || status == 'in_process';
  bool get isCompleted => status == 'completed';

  String get statusDisplay {
    if (isPendingSync) return 'Menunggu koneksi';
    switch (status) {
      case 'available':
        return 'Tersedia';
      case 'requested':
        return 'Diajukan';
      case 'processing':
      case 'in_process':
        return 'Sedang Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    List<String> photos = [];
    if (json['photo_urls'] != null) {
      if (json['photo_urls'] is List) {
        photos = (json['photo_urls'] as List).map((e) => e.toString()).toList();
      }
    }

    return ItemModel(
      id: json['id'] as String,
      donorId: json['donor_id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Lainnya',
      condition: json['condition'] as String? ?? 'Layak Pakai',
      photoUrls: photos,
      location: json['location'] as String? ?? '',
      status: json['status'] as String? ?? 'available',
      acceptedRequestId: json['accepted_request_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      isDraft: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'name': name,
      'description': description,
      'category': category,
      'condition': condition,
      'photo_urls': photoUrls,
      'location': location,
      'status': isPendingSync ? 'available' : status,
      if (acceptedRequestId != null) 'accepted_request_id': acceptedRequestId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Deserialisasi dari Hive box drafts
  factory ItemModel.fromDraftMap(Map<String, dynamic> map) {
    List<String> photos = [];
    if (map['photo_urls'] != null && map['photo_urls'] is List) {
      photos = (map['photo_urls'] as List).map((e) => e.toString()).toList();
    }

    return ItemModel(
      id: map['id'] as String,
      donorId: map['donor_id'] as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Lainnya',
      condition: map['condition'] as String? ?? 'Layak Pakai',
      photoUrls: photos,
      location: map['location'] as String? ?? '',
      status: 'pending_sync',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      isDraft: true,
      localPhotoPath: map['local_photo_path'] as String?,
      syncError: map['sync_error'] as String?,
    );
  }

  /// Serialisasi untuk disimpan ke Hive box drafts
  Map<String, dynamic> toDraftMap() {
    return {
      'id': id,
      'donor_id': donorId,
      'name': name,
      'description': description,
      'category': category,
      'condition': condition,
      'photo_urls': photoUrls,
      'location': location,
      'status': 'pending_sync',
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'local_photo_path': localPhotoPath,
      'sync_error': syncError,
      'is_draft': true,
    };
  }

  ItemModel copyWith({
    String? id,
    String? donorId,
    String? name,
    String? description,
    String? category,
    String? condition,
    List<String>? photoUrls,
    String? location,
    String? status,
    String? acceptedRequestId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDraft,
    String? localPhotoPath,
    String? syncError,
  }) {
    return ItemModel(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      photoUrls: photoUrls ?? this.photoUrls,
      location: location ?? this.location,
      status: status ?? this.status,
      acceptedRequestId: acceptedRequestId ?? this.acceptedRequestId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDraft: isDraft ?? this.isDraft,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      syncError: syncError ?? this.syncError,
    );
  }
}
