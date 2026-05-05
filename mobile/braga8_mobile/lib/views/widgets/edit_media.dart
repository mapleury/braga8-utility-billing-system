import 'package:braga8_mobile/views/widgets/dark_grey_action_button.dart';
import 'package:flutter/material.dart';

class EditMedia extends StatelessWidget {
  final String label;

  const EditMedia({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(
                '../../../../assets/meter-sample.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.black54,
                child: Text(
                  "Click to View Image",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        DarkGreyActionButton(
          label: "Ganti Foto",
          onTap: () {}
        )
      ],
    );
  }
}
