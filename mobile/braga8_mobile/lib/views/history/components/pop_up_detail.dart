import 'package:flutter/material.dart';

class PopUpDetail {
  static void showDetail({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> infoData, 
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 320,
                padding: EdgeInsets.fromLTRB(25, 30, 25, 30),
                decoration: BoxDecoration(
                  color: Color(0xFF131316),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white30, width: .5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25.0),
                        child: Text(
                          title, // Judul dinamis
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ...infoData.map((data) => _buildField(
                          data['label'] ?? "", 
                          data['value'] ?? "",
                        )),
                  ],
                ),
              ),
              Positioned(
                right: -10,
                top: -15,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF382212),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: .5),
                    ),
                    child: Icon(Icons.close, color: Colors.white30, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white38, fontSize: 12)),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}