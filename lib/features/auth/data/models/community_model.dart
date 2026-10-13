/// Model data komunitas dan status legalitas
class CommunityModel {
  final String id;
  final String profileId;
  final String communityName;
  final String? description;
  final String? legalDocumentUrl;
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;
  final DateTime? createdAt;

  const CommunityModel({
    required this.id,
    required this.profileId,
    required this.communityName,
    this.description,
    this.legalDocumentUrl,
    this.verificationStatus = 'pending',
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
    this.createdAt,
  });

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';

  String get verificationStatusDisplay {
    switch (verificationStatus) {
      case 'verified':
        return 'Terverifikasi';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Menunggu Verifikasi';
    }
  }

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      communityName: json['community_name'] as String? ?? '',
      description: json['description'] as String?,
      legalDocumentUrl: json['legal_document_url'] as String?,
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'] as String)
          : null,
      verifiedBy: json['verified_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'community_name': communityName,
      'description': description,
      'legal_document_url': legalDocumentUrl,
      'verification_status': verificationStatus,
      if (verifiedAt != null) 'verified_at': verifiedAt!.toIso8601String(),
      'verified_by': verifiedBy,
      'rejection_reason': rejectionReason,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  CommunityModel copyWith({
    String? id,
    String? profileId,
    String? communityName,
    String? description,
    String? legalDocumentUrl,
    String? verificationStatus,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? rejectionReason,
    bool clearRejectionReason = false,
    DateTime? createdAt,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      communityName: communityName ?? this.communityName,
      description: description ?? this.description,
      legalDocumentUrl: legalDocumentUrl ?? this.legalDocumentUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      rejectionReason: clearRejectionReason
          ? null
          : (rejectionReason ?? this.rejectionReason),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
