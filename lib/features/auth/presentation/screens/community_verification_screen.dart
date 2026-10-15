import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../providers/auth_provider.dart';
import '../providers/community_provider.dart';

/// Layar pendaftaran profil komunitas & unggah dokumen legalitas
class CommunityVerificationScreen extends ConsumerStatefulWidget {
  const CommunityVerificationScreen({super.key});

  @override
  ConsumerState<CommunityVerificationScreen> createState() =>
      _CommunityVerificationScreenState();
}

class _CommunityVerificationScreenState
    extends ConsumerState<CommunityVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final community = ref.read(authNotifierProvider).community;
    final user = ref.read(authNotifierProvider).user;

    _nameController = TextEditingController(
      text: community?.communityName.isNotEmpty == true
          ? community!.communityName
          : (user?.fullName ?? ''),
    );
    _descController = TextEditingController(
      text: community?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Memilih dokumen via file picker (mendukung PDF, PNG, JPG)
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final file = File(path);
        final size = await file.length();

        setState(() {
          _selectedFile = file;
          _selectedFileName = result.files.single.name;
          _selectedFileSize = size;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih berkas: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Memilih dokumen foto langsung dari kamera
  Future<void> _pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        final file = File(picked.path);
        final size = await file.length();
        setState(() {
          _selectedFile = file;
          _selectedFileName = picked.name;
          _selectedFileSize = size;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Format ukuran file dalam KB atau MB
  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Buka dokumen di peramban eksternal
  Future<void> _openDocumentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka tautan dokumen.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Simpan profil komunitas & unggah berkas legalitas
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authNotifierProvider);
    final user = authState.user;
    final community = authState.community;

    if (user == null) return;

    // Jika belum pernah ada dokumen dan sekarang tidak memilih berkas
    if ((community?.legalDocumentUrl == null || community!.legalDocumentUrl!.isEmpty) &&
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih dokumen legalitas (PDF atau foto berkas izin).'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final repo = ref.read(communityRepositoryProvider);

      // 1. Perbarui nama dan deskripsi komunitas
      var updatedCommunity = await repo.updateCommunityProfile(
        profileId: user.id,
        communityName: _nameController.text.trim(),
        description: _descController.text.trim(),
      );

      // 2. Jika ada berkas baru dipilih, upload berkas legalitas
      if (_selectedFile != null) {
        updatedCommunity = await repo.uploadLegalDocumentFile(
          userId: user.id,
          file: _selectedFile!,
        );
      }

      // 3. Perbarui state Riverpod
      ref.read(authNotifierProvider.notifier).updateCommunity(updatedCommunity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil dan dokumen legalitas berhasil dikirim! Menunggu verifikasi admin.'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _selectedFile = null;
          _selectedFileName = null;
          _selectedFileSize = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan dokumen: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final community = authState.community;

    return AppScaffold(
      title: 'Verifikasi Komunitas',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kartu Status Verifikasi
              _buildStatusCard(community),
              const SizedBox(height: AppSizes.md),

              // Bagian Identitas Komunitas
              const Text(
                'Profil Organisasi',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Komunitas / Yayasan *',
                  hintText: 'Contoh: Komunitas Peduli Sesama',
                  prefixIcon: Icon(Icons.apartment),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama komunitas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi & Visi-Misi Organisasi',
                  hintText: 'Jelaskan fokus kegiatan sosial atau penyaluran donasi komunitas Anda',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Bagian Unggah Dokumen Legalitas
              const Text(
                'Dokumen Legalitas',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Unggah dokumen resmi seperti Akta Notaris, SK Kemenkumham, atau Surat Keterangan Domisili Organisasi (format PDF atau gambar).',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Dokumen yang telah ada sebelumnya
              if (community?.legalDocumentUrl != null &&
                  community!.legalDocumentUrl!.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  color: AppColors.primarySwatch.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.task_outlined, color: AppColors.primary),
                    title: const Text(
                      'Dokumen Legalitas Terunggah',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text(
                      'Status saat ini: ${community.verificationStatusDisplay}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Buka Berkas', style: TextStyle(fontSize: 12)),
                      onPressed: () => _openDocumentUrl(community.legalDocumentUrl!),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
              ],

              // Card Berkas Baru yang Dipilih
              if (_selectedFile != null) ...[
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _selectedFileName?.toLowerCase().endsWith('.pdf') == true
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    title: Text(
                      _selectedFileName ?? 'Berkas Terpilih',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _selectedFileSize != null
                          ? _formatFileSize(_selectedFileSize!)
                          : '',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                          _selectedFileName = null;
                          _selectedFileSize = null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
              ],

              // Tombol Pilih Berkas
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Pilih PDF / Gambar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isUploading ? null : _pickFile,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Foto Dokumen'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isUploading ? null : _pickImageFromCamera,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Tombol Submit Form
              AppButton(
                label: community?.legalDocumentUrl != null
                    ? 'Perbarui Data & Berkas'
                    : 'Kirim Dokumen Verifikasi',
                isLoading: _isUploading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kartu status verifikasi dinamis
  Widget _buildStatusCard(dynamic community) {
    final status = community?.verificationStatus ?? 'pending';
    final hasDoc = community?.legalDocumentUrl != null &&
        community!.legalDocumentUrl!.isNotEmpty;

    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String title;
    String desc;

    if (!hasDoc) {
      bgColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade300;
      iconColor = Colors.orange.shade800;
      icon = Icons.warning_amber_rounded;
      title = 'Dokumen Belum Dilengkapi';
      desc =
          'Unggah dokumen legalitas organisasi Anda agar dapat membuat kampanye dan mengajukan permintaan donasi.';
    } else if (status == 'verified') {
      bgColor = AppColors.primarySwatch.shade50;
      borderColor = AppColors.primary.withOpacity(0.5);
      iconColor = AppColors.primary;
      icon = Icons.verified;
      title = 'Komunitas Terverifikasi';
      desc =
          'Akun komunitas Anda sudah terverifikasi resmi oleh CareCycle. Anda memiliki akses penuh ke fitur pengajuan barang dan kampanye.';
    } else if (status == 'rejected') {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      iconColor = AppColors.error;
      icon = Icons.cancel_outlined;
      title = 'Verifikasi Ditolak';
      final reason = community?.rejectionReason ?? 'Dokumen tidak memenuhi persyaratan.';
      desc = 'Alasan: "$reason". Silakan unggah dokumen yang sah untuk diverifikasi ulang.';
    } else {
      // Pending
      bgColor = Colors.amber.shade50;
      borderColor = Colors.amber.shade400;
      iconColor = Colors.amber.shade900;
      icon = Icons.hourglass_top_rounded;
      title = 'Menunggu Verifikasi Admin';
      desc =
          'Dokumen legalitas Anda sedang dalam proses peninjauan oleh tim admin. Proses ini biasanya memakan waktu 1x24 jam kerja.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontSm,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
