import 'package:braga8_mobile/views/widgets/glassy_btn.dart';
import 'package:flutter/material.dart';

class SuccessModal extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;

  const SuccessModal({super.key, required this.title, required this.onConfirm});

  static void show(
    BuildContext context, {
    required String title,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessModal(title: title, onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 150),
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          image: DecorationImage(
            image: AssetImage('../../assets/modal-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("../../assets/success-icon.png", width: 160),
            SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            GlassyBtn(label: "Kembali", onTap: onConfirm),
          ],
        ),
      ),
    );
  }
}
