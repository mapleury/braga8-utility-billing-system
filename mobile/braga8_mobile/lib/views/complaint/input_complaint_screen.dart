import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:braga8_mobile/data/models/complaint_model.dart';
import 'package:braga8_mobile/views/meter_input/meter_camera_screen.dart';
import 'package:braga8_mobile/views/widgets/app_header.dart';
import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';

class InputComplaintScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Complaint? complaint; // pre-filled data when editing
  final bool isEdit;

  const InputComplaintScreen({
    super.key,
    this.onBack,
    this.complaint,
    this.isEdit = false,
  });

  @override
  State<InputComplaintScreen> createState() => _InputComplaintScreenState();
}

class _InputComplaintScreenState extends State<InputComplaintScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // ── Photo ─────────────────────────────────────────────────────────────────────
  File? _photoFile;
  XFile? _photoXFile;
  Uint8List? _photoBytes;

  // ── Submit ────────────────────────────────────────────────────────────────────
  bool _isSubmitting = false;

  // ── Services ──────────────────────────────────────────────────────────────────
  final ApiService _apiService = ApiService();

  // ── Animation ─────────────────────────────────────────────────────────────────
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Colors ────────────────────────────────────────────────────────────────────
  static const _orange = AppColors.primaryOrange;
  Color get _orangeDim => _orange.withOpacity(0.22);
  Color get _orangeBorder => _orange.withOpacity(0.45);
  Color get _glass => Colors.white.withOpacity(0.05);
  Color get _glassBorder => Colors.white.withOpacity(0.12);

  @override
  void initState() {
    super.initState();
    if (widget.complaint != null) {
      _titleController.text = widget.complaint!.title;
      _descController.text = widget.complaint!.description;
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Progress ──────────────────────────────────────────────────────────────────
  double get _progress {
    int filled = 0;
    if (_titleController.text.isNotEmpty) filled++;
    if (_descController.text.isNotEmpty) filled++;
    if (_photoXFile != null) filled++;
    // photo is optional, so max meaningful = 3 but weight it as 2/3 full without photo
    return filled / 3;
  }

  // ── Photo — CAMERA ONLY ───────────────────────────────────────────────────────
  Future<void> _openCamera() async {
    if (kIsWeb) {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (image == null) return;
        final bytes = await image.readAsBytes();
        setState(() {
          _photoXFile = image;
          _photoBytes = bytes;
        });
      } on Exception catch (e) {
        _showSnack("Akses kamera ditolak: $e", isError: true);
      }
      return;
    }

    final XFile? photo = await Navigator.push<XFile>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const MeterCameraScreen(),
      ),
    );

    if (photo == null) return;

    try {
      final bytes = await photo.readAsBytes();
      setState(() {
        _photoXFile = photo;
        _photoBytes = bytes;
        _photoFile = File(photo.path);
      });
    } catch (e) {
      _showSnack("Gagal memproses foto: $e", isError: true);
    }
  }

  void _removePhoto() {
    setState(() {
      _photoXFile = null;
      _photoBytes = null;
      _photoFile = null;
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    double? latitude;
    double? longitude;
    try {
      final position = await _apiService.determinePosition();
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (_) {
      // GPS optional for complaint — proceed without
    }

    final Map<String, dynamic> payload = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    try {
      // Replace with your actual ApiService complaint endpoint
      // final bool success = await _apiService.submitComplaint(payload, _photoXFile);
      // Simulated success for now:
      await Future.delayed(const Duration(seconds: 1));
      final bool success = await _apiService.submitComplaint(
        payload,
        _photoXFile,
        isEdit: widget.isEdit,
        complaintId: widget.complaint?.id,
      );

      if (mounted && success) {
        _showSnack("Komplain berhasil dikirim");
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
        widget.onBack?.call();
      }
    } catch (e) {
      if (mounted)
        _showSnack(e.toString().replaceFirst("Exception: ", ""), isError: true);
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  // ── Snack ─────────────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isError
                      ? Colors.redAccent.withOpacity(0.5)
                      : _orange.withOpacity(0.5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isError
                          ? Colors.redAccent.withOpacity(0.15)
                          : _orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: isError ? Colors.redAccent : _orange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      msg,
                      style: TextStyle(
                        color: isError ? Colors.redAccent : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: MainLayout(
        child: SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppHeader(
                      title: "Ajukan Komplain",
                      titleIcon: Icons.report_problem_rounded,
                      onBack: widget.onBack,
                    ),
                    const SizedBox(height: 10),
                    _buildProgressBar(),
                    const SizedBox(height: 28),

                    // ── STEP 1 — Judul ────────────────────────────────────
                    _buildSectionLabel(
                      "1",
                      "Pasal Komplain",
                      Icons.title_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildTitleField(),

                    // ── STEP 2 — Keterangan ───────────────────────────────
                    const SizedBox(height: 28),
                    _buildSectionLabel(
                      "2",
                      "Keterangan",
                      Icons.description_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildDescField(),

                    // ── STEP 3 — Foto ─────────────────────────────────────
                    const SizedBox(height: 28),
                    _buildSectionLabel(
                      "3",
                      "Foto Bukti (Opsional)",
                      Icons.camera_alt_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoContainer(),

                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 12),
                    _buildCancelButton(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Progress Bar ──────────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Kelengkapan Data",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Text(
                "${(_progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(_orange),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String step, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _orangeDim,
            shape: BoxShape.circle,
            border: Border.all(color: _orangeBorder, width: 1.5),
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: _orange,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: _orange),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Title Field ───────────────────────────────────────────────────────────────
  Widget _buildTitleField() {
    return _glassCard(
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: _titleController,
        maxLength: 100,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: InputBorder.none,
          hintText: "Contoh: Kebocoran Pipa, Gangguan Listrik...",
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(
            Icons.report_problem_outlined,
            color: _orange,
            size: 20,
          ),
          counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty)
            return "Judul komplain wajib diisi";
          if (v.trim().length < 5)
            return "Judul terlalu singkat (min 5 karakter)";
          return null;
        },
      ),
    );
  }

  // ── Description Field ─────────────────────────────────────────────────────────
  Widget _buildDescField() {
    return _glassCard(
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: _descController,
        maxLines: 6,
        maxLength: 500,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          hintText:
              "Jelaskan detail komplain Anda: lokasi, waktu kejadian, dampak yang ditimbulkan...",
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8, top: 12),
            child: Icon(Icons.edit_note_rounded, color: _orange, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return "Keterangan wajib diisi";
          if (v.trim().length < 10)
            return "Keterangan terlalu singkat (min 10 karakter)";
          return null;
        },
      ),
    );
  }

  // ── Photo Container — CAMERA ONLY (OPTIONAL) ─────────────────────────────────
  Widget _buildPhotoContainer() {
    final bool hasPhoto = _photoXFile != null;

    return Column(
      children: [
        GestureDetector(
          onTap: _openCamera,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: hasPhoto ? 220 : 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasPhoto ? _orangeBorder : _glassBorder,
                width: hasPhoto ? 1.8 : 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              boxShadow: hasPhoto
                  ? [
                      BoxShadow(
                        color: _orange.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasPhoto
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        _photoBytes != null
                            ? Image.memory(_photoBytes!, fit: BoxFit.cover)
                            : Image.file(_photoFile!, fit: BoxFit.cover),
                        // Retake overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.72),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  color: _orange,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Ambil Ulang",
                                  style: TextStyle(
                                    color: _orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Success badge
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    )
                  : BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: _glass,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _orangeDim,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _orangeBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: _orange,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Lampirkan Foto Bukti",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Tap untuk membuka kamera",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _chip(Icons.camera_alt_rounded, "Kamera"),
                                const SizedBox(width: 8),
                                _optionalBadge(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
        // Remove photo button
        if (hasPhoto) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _removePhoto,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 14,
                  color: Colors.redAccent.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  "Hapus Foto",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _orangeDim,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _orangeBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _orange),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _orange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: const Text(
        "Opsional",
        style: TextStyle(
          fontSize: 11,
          color: Colors.white38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Save Button ───────────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange.withOpacity(0.3),
          disabledBackgroundColor: Colors.white10,
          padding: const EdgeInsets.symmetric(vertical: 22),
          elevation: 0,
          side: BorderSide(color: _glassBorder, width: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Kirim Komplain",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Cancel Button ─────────────────────────────────────────────────────────────
  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 22),
          side: BorderSide(color: _glassBorder, width: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Batal",
          style: TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ── Glass Card ────────────────────────────────────────────────────────────────
  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _glass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _glassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
