import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/user_model.dart';
import 'package:braga8_mobile/views/dashboard/components/header_navbar.dart';
import 'package:braga8_mobile/views/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'menu_grid.dart';
import 'summary_card.dart';

class DashboardBody extends StatelessWidget {
  final Function(int) onMenuTap;
    final ApiService api;

  const DashboardBody({super.key, required this.onMenuTap, required this.api});

  @override
  Widget build(BuildContext context) {
    final UserModel dummyUser = UserModel(
      username: "@lala_braga",
      joinDate: "Jan 2026",
      email: "lala@gmail.com",
      tenantName: 'lala',
      phone: '08325637593',
      businessType: 'Restaurant',
      companyName: 'Solaria',
      units: [],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderNavbar(user: dummyUser, token: '', api: api,),

          PageHeader(
            title: "Halo, Jimmy!",
            subtitle: "Braga8 Utility Billing Management",
          ),
          SizedBox(height: 30),
          SummaryCard(
            currentValue: 1300000,
            targetValue: 2000000,
            period: "Januari 2026",
          ),
          SizedBox(height: 30),
          _buildMenuGrid(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MenuGrid(
                title: "Meter Analytics",
                imagePath: "assets/cardImage/meter-input-img.png",
                onTap: () => onMenuTap(1),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: MenuGrid(
                title: "Invoices",
                imagePath: "assets/cardImage/daftar-unit-img.png",
                onTap: () => onMenuTap(2),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: MenuGrid(
                title: "History",
                imagePath: "assets/cardImage/history-img.png",
                onTap: () => onMenuTap(3),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: MenuGrid(
                title: "Complaint",
                imagePath: "assets/cardImage/complaint-img.png",
                onTap: () => onMenuTap(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
