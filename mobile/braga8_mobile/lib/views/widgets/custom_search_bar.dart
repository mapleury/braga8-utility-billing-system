import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onSearchPressed;
  final TextEditingController? controller;

  const CustomSearchBar({
    super.key,
    this.hintText = "Cari...",
    this.onChanged,
    this.onSearchPressed,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6A3013).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF76240B).withValues(alpha: 0.1),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: -5,
                      offset: Offset(4, 2),
                    ),
                  ],
                ),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
              ),
            ),

            Center(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(color: Colors.white),
                cursorColor: Color(0xFFC48634),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.white70, size: 22),
                    onPressed: onSearchPressed,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}