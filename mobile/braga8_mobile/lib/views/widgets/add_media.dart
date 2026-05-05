import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AddMedia extends StatelessWidget {
  final String label;
  final VoidCallback onPickImage;
  final String btnText;
  final File? imageFile;

  const AddMedia({
    super.key,
    required this.label,
    required this.onPickImage,
    required this.btnText,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 10),
        InkWell(
          onTap: onPickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              image: imageFile != null ? DecorationImage(
                image: kIsWeb 
                    ? NetworkImage(imageFile!.path) 
                    : FileImage(imageFile!) as ImageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
              ) : null,
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(btnText, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}