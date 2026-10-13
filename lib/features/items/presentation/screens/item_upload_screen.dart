import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/ml_kit_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/item_provider.dart';

/// Layar untuk mengunggah barang donasi baru
class ItemUploadScreen extends ConsumerStatefulWidget {
  const ItemUploadScreen({super.key});

  @override
  ConsumerState<ItemUploadScreen> createState() => _ItemUploadScreenState();
}

class _ItemUploadScreenState extends ConsumerState<ItemUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  File? _imageFile;
  bool _isAnalyzingImage = false;
  bool _isSubmitting = false;
  bool _isOnline = true;

  String _selectedCategory = 'Pakaian';
  String _selectedCondition = 'Layak Pakai';
  MlCategorySuggestion? _aiSuggestion;

  final List<String> _conditions = ['Layak Pakai', 'Sangat Baik', 'Baru'];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    final user = ref.read(authNotifierProvider).user;
    if (user?.address != null && user!.address!.isNotEmpty) {
      _locationController.text = user.address!;
    }
  }

  Future<void> _checkConnectivity() async {
    final connected = await ConnectivityService.isConnected();
    if (mounted) {
      setState(() {
        _isOnline = connected;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Ambil foto dari kamera atau galeri
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _imageFile = file;
          _isAnalyzingImage = true;
          _aiSuggestion = null;
        });

        // Jalankan Google ML Kit on-device image labeling
        final suggestion = await MlKitService.classifyImage(file);

        if (mounted) {
          setState(() {
            _isAnalyzingImage = false;
            _aiSuggestion = suggestion;
            if (suggestion.hasRecommendation) {
              _selectedCategory = suggestion.category;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Kirim donasi (Online) atau Simpan Draft (Offline)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap sertakan foto barang donasi Anda.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repo = ref.read(itemRepositoryProvider);
      final item = await repo.createItem(
        donorId: user.id,
        name: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        condition: _selectedCondition,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : 'Indonesia',
        photoFile: _imageFile,
      );

      // Muat ulang daftar barang donatur
      await ref.read(myItemsNotifierProvider.notifier).loadItems();

      if (mounted) {
        if (item.isPendingSync) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Barang disimpan sebagai draft lokal (offline). Akan otomatis diunggah saat koneksi pulih.',
              ),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barang berhasil didonasikan dan masuk ke katalog!'),
              backgroundColor: AppColors.success,
            ),
          );
        }

        context.pushReplacementNamed(AppRouter.myItems);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan barang: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Unggah Donasi Barang',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Peringatan Mode Offline jika tidak ada koneksi
              if (!_isOnline) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.amber, size: 24),
                      SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          'Anda sedang offline. Barang akan disimpan di perangkat sebagai draft dan otomatis diunggah saat koneksi pulih.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],

              // Bagian Unggah Foto Barang
              _buildPhotoPickerSection(),
              const SizedBox(height: AppSizes.md),

              // Banner Rekomendasi Kategori oleh AI ML Kit
              if (_isAnalyzingImage) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySwatch.shade50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          'AI sedang menganalisis gambar untuk menyarankan kategori...',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ] else if (_aiSuggestion != null) ...[
                _buildAiSuggestionCard(_aiSuggestion!),
                const SizedBox(height: AppSizes.md),
              ],

              // Input Judul Barang
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Barang *',
                  hintText: 'Contoh: Kemeja Formal Pria Ukuran L',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul barang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Pilihan Kategori (Pakaian, Buku, Elektronik, Alat Sekolah, Lainnya)
              const Text(
                'Kategori Barang *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSm,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: MlKitService.availableCategories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final isAiRecommended = _aiSuggestion?.category == cat;

                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat),
                        if (isAiRecommended) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primarySwatch.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.md),

              // Pilihan Kondisi Barang
              const Text(
                'Kondisi Barang *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSm,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _conditions.map((cond) {
                  final isSelected = _selectedCondition == cond;
                  return ChoiceChip(
                    label: Text(cond),
                    selected: isSelected,
                    selectedColor: AppColors.primarySwatch.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCondition = cond;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.md),

              // Input Lokasi Pengambilan / Kota
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi / Kota Pengambilan',
                  hintText: 'Contoh: Bandung, Jawa Barat',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Input Deskripsi Barang
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Lengkap *',
                  hintText: 'Jelaskan kondisi barang, ukuran, kelengkapan, dan alasan donasi',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Deskripsi barang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.xl),

              // Tombol Donasikan / Simpan Draft
              AppButton(
                label: _isOnline ? 'Donasikan Barang' : 'Simpan Draft (Offline)',
                isLoading: _isSubmitting,
                icon: _isOnline ? Icons.volunteer_activism : Icons.save_alt,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bagian pemilih foto kamera & galeri
  Widget _buildPhotoPickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Barang *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontSm,
          ),
        ),
        const SizedBox(height: 8),

        if (_imageFile != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Image.file(
                  _imageFile!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                        _aiSuggestion = null;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ] else ...[
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih atau foto barang donasi',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI akan otomatis menganalisis gambar untuk menyarankan kategori',
                    style: TextStyle(color: AppColors.primary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamera'),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeri'),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Kartu rekomendasi kategori dari AI ML Kit
  Widget _buildAiSuggestionCard(MlCategorySuggestion suggestion) {
    if (!suggestion.hasRecommendation) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 20, color: Colors.grey),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                'AI belum dapat mengenali kategori spesifik (terdeteksi: ${suggestion.matchedLabel.isNotEmpty ? suggestion.matchedLabel : "objek umum"}). Silakan pilih kategori secara manual.',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySwatch.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Saran Kategori AI: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      suggestion.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Dikenali dari objek "${suggestion.matchedLabel}" (akurasi ${(suggestion.confidence * 100).toStringAsFixed(0)}%). Anda bebas mengubah kategori di bawah ini.',
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
