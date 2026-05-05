import 'package:flutter/material.dart';

class LightBrownBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String label;

  const LightBrownBtn({
    super.key,
    this.onTap,
    this.isLoading = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          height: 10,
          padding: EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [Color(0xFF1A1A1A), Color(0xFF808080)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF7A4A2D).withValues(alpha: 0.5),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
              BoxShadow(
                color: Color(0xFFFA6C2A).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 77, 36, 15),
              borderRadius: BorderRadius.circular(14.5),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
