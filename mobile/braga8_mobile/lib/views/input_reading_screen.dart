import 'dart:io';
import 'dart:ui';
import 'package:braga8_mobile/views/widgets/app_header.dart';
import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:braga8_mobile/views/widgets/success_modal.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';

class InputReadingScreen extends StatefulWidget {
  final Unit? unit;
  final String? category;
  final bool isEdit;
  final String? initialValue;
  final VoidCallback? onBack;

  const InputReadingScreen({
    super.key,
    this.unit,
    this.category,
    this.isEdit = false,
    this.initialValue,
    this.onBack,
  });

  @override
  State<InputReadingScreen> createState() => _InputReadingScreenState();
}

class _InputReadingScreenState extends State<InputReadingScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _meterController = TextEditingController();
  final _noteController = TextEditingController();

  // ── Dropdown ──────────────────────────────────────────────────────────────────
  List<Tenant> _tenants = [];
  Unit? _selectedUnit;
  String _selectedCategory = "Electric";
  bool _isLoadingTenants = true;

  // ── NEW: Selected Meter ───────────────────────────────────────────────────────
  Meter? _selectedMeter;

  // ── Photo ─────────────────────────────────────────────────────────────────────
  File? _photoFile;
  XFile? _photoXFile;
  Uint8List? _photoBytes;
  final ImagePicker _picker = ImagePicker();

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
    if (widget.unit != null) _selectedUnit = widget.unit;
    if (widget.category != null) _selectedCategory = widget.category!;
    if (widget.initialValue != null)
      _meterController.text = widget.initialValue!;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadTenants();
  }

  @override
  void dispose() {
    _meterController.dispose();
    _noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────────
  Future<void> _loadTenants() async {
    try {
      final tenants = await _apiService.fetchUnitsSummary();
      setState(() {
        _tenants = tenants;
        _isLoadingTenants = false;
        // Auto-select meter if unit was pre-selected (coming from DetailUnitScreen)
        if (_selectedUnit != null) {
          _autoSelectMeter();
        }
      });
    } catch (e) {
      setState(() => _isLoadingTenants = false);
      if (mounted) _showSnack("Gagal memuat data unit: $e", isError: true);
    }
  }

  /// Returns meters for the currently selected unit filtered by category.
  List<Meter> get _availableMeters {
    if (_selectedUnit == null || _selectedUnit!.meters == null) return [];
    final typeFilter = _selectedCategory == "Electric"
        ? "electricity"
        : "water";
    return _selectedUnit!.meters!
        .where((m) => m.meterType == typeFilter)
        .toList();
  }

  bool get _isAlreadySubmitted {
    if (_selectedUnit == null) return false;
    if (_selectedCategory == "Electric") return _selectedUnit!.isElecChecked;
    if (_selectedCategory == "Water") return _selectedUnit!.isWaterChecked;
    return false;
  }

  /// Called when unit or category changes — resets and auto-picks meter.
  void _autoSelectMeter() {
    final meters = _availableMeters;
    if (meters.length == 1) {
      // Only one option — pick it automatically
      _selectedMeter = meters.first;
    } else {
      // Multiple or none — force user to pick
      _selectedMeter = null;
    }
  }

  // ── Photo picker ──────────────────────────────────────────────────────────────
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      setState(() {
        _photoXFile = image;
        _photoBytes = bytes;
        if (!kIsWeb) _photoFile = File(image.path);
      });
    } on PlatformException catch (e) {
      _showSnack("Akses ditolak: ${e.message}", isError: true);
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: _glassBorder, width: 1.2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  "Pilih Sumber Foto",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (!kIsWeb) ...[
                      Expanded(
                        child: _sourceOption(
                          icon: Icons.camera_alt_rounded,
                          label: "Kamera",
                          onTap: () {
                            Navigator.pop(context);
                            _pickPhoto(ImageSource.camera);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: _sourceOption(
                        icon: Icons.photo_library_rounded,
                        label: "Galeri",
                        onTap: () {
                          Navigator.pop(context);
                          _pickPhoto(ImageSource.gallery);
                        },
                      ),
                    ),
                    if (!kIsWeb) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _sourceOption(
                          icon: Icons.folder_open_rounded,
                          label: "File",
                          onTap: () {
                            Navigator.pop(context);
                            _pickPhoto(ImageSource.gallery);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _orangeDim,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _orangeBorder, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, color: _orange, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUnit == null) {
      _showSnack("Pilih unit terlebih dahulu", isError: true);
      return;
    }

    if (!widget.isEdit && _isAlreadySubmitted) {
      _showSnack(
        "Meteran ${_selectedCategory.toLowerCase()} unit ini sudah diinput bulan ini",
        isError: true,
      );
      return;
    }

    if (_selectedMeter == null) {
      _showSnack("Pilih meteran terlebih dahulu", isError: true);
      return;
    }

    if (_photoXFile == null) {
      _showSnack("Foto bukti meter wajib diupload", isError: true);
      return;
    }

    // ── Validate reading value > previous ────────────────────────────
    final double? newValue = double.tryParse(_meterController.text.trim());
    if (newValue == null) {
      _showSnack("Angka meter tidak valid", isError: true);
      return;
    }

    final bool isElectricCheck = _selectedCategory == "Electric";
    final String? prevValueStr = isElectricCheck
        ? _selectedUnit!.elecReadingValue
        : _selectedUnit!.waterReadingValue;
    final double? prevValue = prevValueStr != null
        ? double.tryParse(prevValueStr)
        : null;

    if (prevValue != null && !widget.isEdit) {
      final double maxElec = 99999.9;
      final double maxWater = 99999.0;
      final double maxValue = isElectricCheck ? maxElec : maxWater;

      // Allow reset to zero only if previous was at max
      final bool isReset = prevValue >= maxValue && newValue == 0;

      if (!isReset && newValue <= prevValue) {
        _showSnack(
          "Nilai meter harus lebih besar dari sebelumnya (${prevValue.toStringAsFixed(isElectricCheck ? 1 : 0)})"
          "${prevValue >= maxValue ? ' atau 0 jika sudah reset' : ''}",
          isError: true,
        );
        return;
      }
    }
    double? latitude;
    double? longitude;
    try {
      final position = await _apiService.determinePosition();
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      if (mounted)
        _showSnack(
          "GPS tidak tersedia. Aktifkan lokasi dan coba lagi.",
          isError: true,
        );
      return;
    }

    setState(() => _isSubmitting = true);
    final bool isElectric = _selectedCategory == "Electric";
    final int? readingId = widget.isEdit
        ? (isElectric
              ? _selectedUnit!.elecReadingId
              : _selectedUnit!.waterReadingId)
        : null;

    final Map<String, dynamic> payload = {
      'unit_id': _selectedUnit!.id,
      'meter_type': _selectedCategory == "Electric"
          ? "electricity"
          : "water",
      'reading_value': _meterController.text.trim(),
      'latitude': latitude,
      'longitude': longitude,
      if (_noteController.text.trim().isNotEmpty)
        'description': _noteController.text.trim(),
    };
    try {
      final bool success = await _apiService.submitMeterReading(
        payload,
        _photoXFile,
        unitId: _selectedUnit!.id,
        meterId: _selectedMeter!.id,
        isEdit: widget.isEdit,
        readingId: readingId,
      );
      if (mounted && success) {
        // Refresh unit data so isElecChecked / isWaterChecked is up-to-date
        final updatedUnit = _selectedUnit!.copyWith(
          isElecChecked: _selectedCategory == "Electric"
              ? true
              : _selectedUnit!.isElecChecked,
          isWaterChecked: _selectedCategory == "Water"
              ? true
              : _selectedUnit!.isWaterChecked,
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              category: _selectedCategory,
              isElecChecked: updatedUnit.isElecChecked,
              isWaterChecked: updatedUnit.isWaterChecked,
              onBack: () {
                Navigator.pop(context); // close SuccessScreen
                Navigator.pop(context, true); // back to DetailUnit
              },
              onInputElectric: () {
                Navigator.pop(context); // close SuccessScreen
                // Replace current InputReadingScreen with a fresh Electric one
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InputReadingScreen(
                      unit: updatedUnit,
                      category: "Electric",
                    ),
                  ),
                );
              },
              onInputWater: () {
                Navigator.pop(context); // close SuccessScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InputReadingScreen(
                      unit: updatedUnit,
                      category: "Water",
                    ),
                  ),
                );
              },
            ),
          ),
        );

        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        _showSnack(e.toString().replaceFirst("Exception: ", ""), isError: true);
    }
    setState(() => _isSubmitting = false);
  }

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
    final bool isElectric = _selectedCategory == "Electric";

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: MainLayout(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: _isLoadingTenants
                ? Center(child: CircularProgressIndicator(color: _orange))
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppHeader(
                            title: widget.isEdit
                                ? "Edit Pembacaan"
                                : "Input Meter Baru",
                            titleIcon: widget.isEdit
                                ? Icons.edit_rounded
                                : Icons.speed_rounded,
                            onBack: widget.onBack,
                          ),
                          const SizedBox(height: 10),
                          _buildProgressBar(),
                          const SizedBox(height: 28),

                          // ── STEP 1: Unit + Category ──────────────────────
                          _buildSectionLabel(
                            "1",
                            "Pilih Unit",
                            Icons.apartment_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildUnitDropdown(),
                          const SizedBox(height: 10),
                          _buildCategoryToggle(),

                          // ── STEP 2: Meter Selection (NEW) ────────────────
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            "2",
                            isElectric
                                ? "Pilih Meteran Listrik"
                                : "Pilih Meteran Air",
                            isElectric
                                ? Icons.electrical_services_rounded
                                : Icons.water_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildMeterDropdown(),

                          // ── STEP 3: Reading value ────────────────────────
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            "3",
                            isElectric
                                ? "Angka Meter Listrik"
                                : "Angka Meter Air",
                            isElectric
                                ? Icons.bolt_rounded
                                : Icons.water_drop_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildMeterField(isElectric),

                          // ── STEP 4: Note ─────────────────────────────────
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            "4",
                            "Catatan (Opsional)",
                            Icons.notes_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildNoteField(),

                          // ── STEP 5: Photo ─────────────────────────────────
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            "5",
                            "Foto Bukti Meter",
                            Icons.camera_alt_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildPhotoContainer(),

                          const SizedBox(height: 40),
                          _buildSaveButton(),
                          const SizedBox(height: 12),
                          _buildCancelButton(),
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
    int filled = 0;
    if (_selectedUnit != null) filled++;
    if (_selectedMeter != null) filled++;
    if (_meterController.text.isNotEmpty) filled++;
    if (_photoXFile != null) filled++;
    final double progress = filled / 4;

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
                "${(progress * 100).toInt()}%",
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
              value: progress,
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

  // ── Unit Dropdown ─────────────────────────────────────────────────────────────
  Widget _buildUnitDropdown() {
    final List<_UnitOption> options = [];
    for (var tenant in _tenants) {
      for (var unit in tenant.units) {
        options.add(_UnitOption(tenant: tenant, unit: unit));
      }
    }

    return _glassCard(
      padding: EdgeInsets.zero,
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<int>(
          value: _selectedUnit?.id,
          isExpanded: true,
          dropdownColor: const Color(0xFF1C1A1E),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _orange),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: InputBorder.none,
            hintText: "Pilih unit...",
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _orange, size: 20),
          ),
          validator: (v) => v == null ? "Unit wajib dipilih" : null,
          items: options.map((opt) {
            return DropdownMenuItem<int>(
              value: opt.unit.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    opt.tenant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Unit ${opt.unit.unitNumber} · Lantai ${opt.unit.floor}",
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (int? val) {
            if (val == null) return;
            for (var opt in options) {
              if (opt.unit.id == val) {
                setState(() {
                  _selectedUnit = opt.unit;
                  _autoSelectMeter(); // reset meter when unit changes
                });
                break;
              }
            }
          },
          selectedItemBuilder: (context) => options.map((opt) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${opt.tenant.name} · Unit ${opt.unit.unitNumber} · Lt.${opt.unit.floor}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Category Toggle ───────────────────────────────────────────────────────────
  Widget _buildCategoryToggle() {
    if (widget.category != null) return const SizedBox.shrink();

    return _glassCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _categoryChip("Electric", Icons.bolt_rounded),
          _categoryChip("Water", Icons.water_drop_rounded),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, IconData icon) {
    final bool isSelected = _selectedCategory == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedCategory = label;
          _autoSelectMeter(); // reset meter when category changes
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? _orangeDim : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _orangeBorder : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? _orange : Colors.white38,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _orange : Colors.white38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── NEW: Meter Dropdown ───────────────────────────────────────────────────────
  Widget _buildMeterDropdown() {
    final meters = _availableMeters;

    // No unit selected yet
    if (_selectedUnit == null) {
      return _glassCard(
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.white38, size: 18),
            const SizedBox(width: 10),
            const Text(
              "Pilih unit terlebih dahulu",
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (!widget.isEdit && _isAlreadySubmitted) {
      return _glassCard(
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.greenAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Meteran ${_selectedCategory.toLowerCase()} unit ini sudah diinput bulan ini",
                style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }
    // Unit selected but no meters for this category
    if (meters.isEmpty) {
      return _glassCard(
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orangeAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Unit ini tidak memiliki meteran ${_selectedCategory.toLowerCase()}",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _glassCard(
      padding: EdgeInsets.zero,
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<int>(
          value: _selectedMeter?.id,
          isExpanded: true,
          dropdownColor: const Color(0xFF1C1A1E),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _orange),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: InputBorder.none,
            hintText: "Pilih nomor meteran...",
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            prefixIcon: Icon(
              _selectedCategory == "Electric"
                  ? Icons.electrical_services_rounded
                  : Icons.water_rounded,
              color: _orange,
              size: 20,
            ),
          ),
          validator: (v) => v == null ? "Meteran wajib dipilih" : null,
          items: meters.map((meter) {
            return DropdownMenuItem<int>(
              value: meter.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meter.meterNumber ?? "Meteran #${meter.id}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _meterSubtitle(meter),
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (int? val) {
            if (val == null) return;
            setState(() {
              _selectedMeter = meters.firstWhere((m) => m.id == val);
            });
          },
          selectedItemBuilder: (context) => meters.map((meter) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                meter.meterNumber ?? "Meteran #${meter.id}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Helper: build a readable subtitle for a meter row.
  String _meterSubtitle(Meter meter) {
    final parts = <String>[];
    if (meter.meterType != null) {
      parts.add(meter.meterType == 'electricity' ? 'Listrik' : 'Air');
    }
    if (meter.meterNumber != null) parts.add("No. ${meter.meterNumber}");
    return parts.isEmpty ? "Meteran #${meter.id}" : parts.join(' · ');
  }

  // ── Meter Reading Field ───────────────────────────────────────────────────────
  Widget _buildMeterField(bool isElectric) {
    return _glassCard(
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: _meterController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: _orange,
          letterSpacing: 2,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: InputBorder.none,
          hintText: "0",
          hintStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white12,
          ),
          suffixText: isElectric ? "kWh" : "m³",
          suffixStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _orange,
          ),
          prefixIcon: Icon(
            isElectric ? Icons.bolt_rounded : Icons.water_drop_rounded,
            color: _orange,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return "Angka meter wajib diisi";
          if (double.tryParse(v) == null) return "Masukkan angka yang valid";
          return null;
        },
      ),
    );
  }

  // ── Note Field ────────────────────────────────────────────────────────────────
  Widget _buildNoteField() {
    return _glassCard(
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: _noteController,
        maxLines: 3,
        maxLength: 200,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          hintText: "Tambah catatan jika diperlukan... (opsional)",
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
      ),
    );
  }

  // ── Photo Container ───────────────────────────────────────────────────────────
  Widget _buildPhotoContainer() {
    final bool hasPhoto = _photoXFile != null;

    return GestureDetector(
      onTap: _showPhotoSourceSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: hasPhoto ? 220 : 175,
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
                              "Ganti Foto",
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
                          width: 58,
                          height: 58,
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
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Upload Foto Bukti Meter",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Tap untuk pilih sumber foto",
                          style: TextStyle(fontSize: 12, color: Colors.white38),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!kIsWeb) ...[
                              _miniChip(Icons.camera_alt_rounded, "Kamera"),
                              const SizedBox(width: 8),
                            ],
                            _miniChip(Icons.photo_library_rounded, "Galeri"),
                            if (!kIsWeb) ...[
                              const SizedBox(width: 8),
                              _miniChip(Icons.folder_open_rounded, "File"),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
                  const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.isEdit ? "Simpan Perubahan" : "Simpan Data",
                    style: const TextStyle(
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

  // ── Glass card helper ─────────────────────────────────────────────────────────
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

// ── Helper ────────────────────────────────────────────────────────────────────
class _UnitOption {
  final Tenant tenant;
  final Unit unit;
  _UnitOption({required this.tenant, required this.unit});
}
