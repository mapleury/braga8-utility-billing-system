
import 'package:braga8_mobile/data/models/user_model.dart';
import 'package:braga8_mobile/views/dashboard/components/gradient_border_btn.dart';
import 'package:flutter/material.dart';

class AccountModalTenant extends StatelessWidget {
  final UserModel user;

  const AccountModalTenant({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Card Utama
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Color(0xFF131316),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: .3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: .1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Account Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF7D1C0A), Color(0xFFFA6C2A)],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: Color(0xFFD2B4A6),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF7A4A32),
                          size: 40,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.tenantName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "@${user.username.replaceFirst('@', '')}",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        "Tenant Name",
                        user.tenantName,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoTile(
                        "Phone",
                        user.phone,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        "Business Type",
                        user.businessType,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoTile(
                        "Company Name",
                        user.companyName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildInfoTile("Email", user.email)),
                    Expanded(child: _buildInfoTile("Join Date", user.joinDate)),
                  ],
                ),

                SizedBox(height: 35),

                Row(
                  children: [
                    Expanded(
                      child: GradientBorderBtn(
                        label: "Edit Account",
                        buttonColor: Color(0xFF3D2616),
                        icon: Icons.edit,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GradientBorderBtn(
                        label: "Logout",
                        buttonColor: Color(0xFF421C1C),
                        icon: Icons.logout,
                        onTap: () {},
                      ),
                    ),
                  ],
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

  Widget _buildInfoTile(
    String label,
    String value, {
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 13)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
