import 'package:flutter/material.dart';


class NotificationModal extends StatelessWidget {
  const NotificationModal({super.key});


  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {"title": "Unit 2A Meter Reading was Added!", "time": "15:30 3 March 2026"},
      {"title": "Unit 2A Meter Reading was Added!", "time": "15:30 3 March 2026"},
      {"title": "Unit 2A Meter Reading was Added!", "time": "15:30 3 March 2026"},
      {"title": "Unit 2A Meter Reading was Added!", "time": "15:30 3 March 2026"},
      {"title": "Unit 2A Meter Reading was Added!", "time": "15:30 3 March 2026"},
      {"title": "Unit 2A Meter Reading was Added!", "time": "15:30 3 March 2026"},
    ];


    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 35, 24, 25),
            decoration: BoxDecoration(
              color: Color(0xFF131316),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: .3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: .10),
                  blurRadius: 10,
                  spreadRadius: 2,
            ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Notifications",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 25),
               
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(
                        notifications[index]['title']!,
                        notifications[index]['time']!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2D1B19),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationItem(String title, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            decoration: BoxDecoration(
              color: Color(0x22717171),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: .2),
                width: 0.8,
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              time,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .4),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

