import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';

class SuccessScreen extends StatefulWidget {
  final String category;
  final bool isElecChecked;
  final bool isWaterChecked;
  final VoidCallback onBack;
  final VoidCallback? onInputElectric;
  final VoidCallback? onInputWater;

  const SuccessScreen({
    super.key,
    required this.category,
    required this.isElecChecked,
    required this.isWaterChecked,
    required this.onBack,
    this.onInputElectric,
    this.onInputWater,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  static const _orange = AppColors.primaryOrange;

  late final AnimationController _iconCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _btnCtrl;

  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();

    // ── Icon: pop in ──────────────────────────────────────────────
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = CurvedAnimation(
      parent: _iconCtrl,
      curve: Curves.elasticOut,
    );
    _iconOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // ── Text: fade + slide up ─────────────────────────────────────
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    // ── Buttons: staggered fade + slide up ───────────────────────
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _btnFade = CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut);
    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut));

    // ── Chain animations ──────────────────────────────────────────
    _iconCtrl.forward().then((_) {
      _contentCtrl.forward().then((_) {
        _btnCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _contentCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showElecBtn = widget.category == "Water" && !widget.isElecChecked;
    final bool showWaterBtn = widget.category == "Electric" && !widget.isWaterChecked;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ──────────────────────────────────────────
          Image.asset('assets/modal-bg.png', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),

          // ── Content ─────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // ── Animated icon ─────────────────────────────
                  FadeTransition(
                    opacity: _iconOpacity,
                    child: ScaleTransition(
                      scale: _iconScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow ring
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _orange.withOpacity(0.25),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          Image.asset('assets/success-icon.png', width: 150),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Animated text ─────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          const Text(
                            "Data Berhasil Disimpan!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Meteran ${widget.category == 'Electric' ? 'listrik' : 'air'} "
                            "berhasil direkam untuk bulan ini.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Animated buttons ──────────────────────────
                  FadeTransition(
                    opacity: _btnFade,
                    child: SlideTransition(
                      position: _btnSlide,
                      child: Column(
                        children: [
                          if (showElecBtn) ...[
                            _ActionButton(
                              icon: Icons.bolt_rounded,
                              label: "Input Meter Listrik",
                              onTap: widget.onInputElectric!,
                              filled: true,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (showWaterBtn) ...[
                            _ActionButton(
                              icon: Icons.water_drop_rounded,
                              label: "Input Meter Air",
                              onTap: widget.onInputWater!,
                              filled: true,
                            ),
                            const SizedBox(height: 12),
                          ],
                          _ActionButton(
                            icon: Icons.arrow_back_rounded,
                            label: "Kembali ke Detail Unit",
                            onTap: widget.onBack,
                            filled: false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Extracted button widget ───────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  static const _orange = AppColors.primaryOrange;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 17),
                decoration: BoxDecoration(
                  color: widget.filled
                      ? _orange.withOpacity(_pressed ? 0.35 : 0.22)
                      : Colors.white.withOpacity(_pressed ? 0.10 : 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.filled
                        ? _orange.withOpacity(0.55)
                        : Colors.white.withOpacity(0.15),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.filled ? _orange : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.filled ? _orange : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}