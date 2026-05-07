import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';

/// A full-screen camera overlay for capturing meter readings.
///
/// Usage:
/// ```dart
/// final XFile? photo = await Navigator.push<XFile>(
///   context,
///   MaterialPageRoute(builder: (_) => const MeterCameraScreen()),
/// );
/// if (photo != null) { /* use photo */ }
/// ```
class MeterCameraScreen extends StatefulWidget {
  const MeterCameraScreen({super.key});

  @override
  State<MeterCameraScreen> createState() => _MeterCameraScreenState();
}

class _MeterCameraScreenState extends State<MeterCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _flashOn = false;
  String? _errorMessage;

  static const _orange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _errorMessage = "Tidak ada kamera yang tersedia.");
        return;
      }

      // Prefer rear camera
      final rear = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final ctrl = CameraController(
        rear,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await ctrl.initialize();
      if (!mounted) return;

      setState(() {
        _controller = ctrl;
        _isInitialized = true;
      });
    } on CameraException catch (e) {
      setState(() => _errorMessage = "Kamera error: ${e.description}");
    }
  }

  Future<void> _capture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);
    HapticFeedback.mediumImpact();

    try {
      final XFile photo = await ctrl.takePicture();
      if (mounted) Navigator.pop(context, photo);
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil foto: ${e.description}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _toggleFlash() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    final next = _flashOn ? FlashMode.off : FlashMode.torch;
    await ctrl.setFlashMode(next);
    setState(() => _flashOn = !_flashOn);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _errorMessage != null
            ? _buildError()
            : !_isInitialized
            ? _buildLoading()
            : _buildCamera(),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────────
  Widget _buildError() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_rounded, color: Colors.white38, size: 64),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white54),
            label: const Text(
              "Kembali",
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading state ─────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryOrange),
    );
  }

  // ── Main camera UI ────────────────────────────────────────────────────────────
  Widget _buildCamera() {
    final size = MediaQuery.of(context).size;
    final ctrl = _controller!;

    // Scale preview to fill screen
    final previewRatio = ctrl.value.aspectRatio;
    final screenRatio = size.width / size.height;
    final scale = screenRatio < previewRatio
        ? size.height * previewRatio / size.width
        : size.width / (size.height * previewRatio);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Camera preview ───────────────────────────────────────────────────
        Transform.scale(
          scale: scale,
          child: Center(child: CameraPreview(ctrl)),
        ),

        // ── Dark vignette edges ──────────────────────────────────────────────
        _buildVignette(),

        // ── Viewfinder / framing guide ───────────────────────────────────────
        _buildFramingGuide(size),

        // ── Top bar ──────────────────────────────────────────────────────────
        _buildTopBar(),

        // ── Badge overlay ────────────────────────────────────────────────────
        _buildBadge(),

        // ── Bottom controls ──────────────────────────────────────────────────
        _buildBottomControls(),
      ],
    );
  }

  // ── Vignette ──────────────────────────────────────────────────────────────────
  Widget _buildVignette() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
        ),
      ),
    );
  }

  // ── Framing Guide ─────────────────────────────────────────────────────────────
  Widget _buildFramingGuide(Size size) {
    const double guideW = 280;
    const double guideH = 160;

    return Center(
      child: SizedBox(
        width: guideW,
        height: guideH,
        child: Stack(
          children: [
            // Corner brackets — top-left
            _corner(Alignment.topLeft, [
              const Offset(0, 24),
              const Offset(0, 0),
              const Offset(24, 0),
            ]),
            // top-right
            _corner(Alignment.topRight, [
              const Offset(-24, 0),
              const Offset(0, 0),
              const Offset(0, 24),
            ]),
            // bottom-left
            _corner(Alignment.bottomLeft, [
              const Offset(0, -24),
              const Offset(0, 0),
              const Offset(24, 0),
            ]),
            // bottom-right
            _corner(Alignment.bottomRight, [
              const Offset(-24, 0),
              const Offset(0, 0),
              const Offset(0, -24),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _corner(Alignment alignment, List<Offset> points) {
    return Align(
      alignment: alignment,
      child: CustomPaint(
        size: const Size(32, 32),
        painter: _CornerPainter(points: points, color: _orange),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Close button
              _iconButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
                tooltip: "Tutup",
              ),
              const Spacer(),
              // Flash toggle
              _iconButton(
                icon: _flashOn
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                onTap: _toggleFlash,
                tooltip: "Flash",
                isActive: _flashOn,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? '',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? _orange.withOpacity(0.25)
                : Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? _orange.withOpacity(0.7)
                  : Colors.white.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Icon(icon, color: isActive ? _orange : Colors.white, size: 20),
        ),
      ),
    );
  }

  // ── Orange badge ──────────────────────────────────────────────────────────────
  Widget _buildBadge() {
    return Positioned(
      // Sits just below the top bar, horizontally centred
      top: MediaQuery.of(context).padding.top + 72,
      left: 24,
      right: 24,
      child: Center(child: _OrangeBadge()),
    );
  }

  // ── Bottom controls ───────────────────────────────────────────────────────────
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hint text
              const Text(
                "Arahkan kamera ke angka meter",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 28),

              // Shutter row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer (left)
                  const SizedBox(width: 80),

                  // Shutter button
                  GestureDetector(
                    onTap: _capture,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: _isCapturing ? 68 : 76,
                      height: _isCapturing ? 68 : 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: _orange, width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: _orange.withOpacity(0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isCapturing
                          ? Padding(
                              padding: const EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                color: _orange,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Icon(
                              Icons.camera_alt_rounded,
                              color: _orange,
                              size: 30,
                            ),
                    ),
                  ),

                  // Spacer (right — mirrors left)
                  const SizedBox(width: 80),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Orange badge widget ───────────────────────────────────────────────────────
class _OrangeBadge extends StatefulWidget {
  const _OrangeBadge();

  @override
  State<_OrangeBadge> createState() => _OrangeBadgeState();
}

class _OrangeBadgeState extends State<_OrangeBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.55),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 17),
            SizedBox(width: 8),
            Text(
              "Pastikan Angka Meter terlihat!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Corner bracket painter ────────────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  const _CornerPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.points != points;
}
