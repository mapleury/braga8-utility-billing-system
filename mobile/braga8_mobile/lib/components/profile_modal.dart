import 'dart:ui';
import 'package:braga8_mobile/services/session_services.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:braga8_mobile/ApiService.dart';

void showProfileModal(
  BuildContext context,
  ApiService api,
  String role,
  String token,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color.fromARGB(0, 60, 60, 60),
    builder: (context) =>
        ProfileControllerSheet(api: api, role: role, token: token),
  );
}

class ProfileControllerSheet extends StatefulWidget {
  final ApiService api;
  final String role;
  final String token;

  const ProfileControllerSheet({
    super.key,
    required this.api,
    required this.role,
    required this.token,
  });

  @override
  State<ProfileControllerSheet> createState() => _ProfileControllerSheetState();
}

class _ProfileControllerSheetState extends State<ProfileControllerSheet> {
  bool isEditing = false;
  bool isSaving = false;
  bool showLogoutConfirm = false;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController picController;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    final user = widget.api.currentUser;
    final tenant = user?['tenant_details'];

    nameController = TextEditingController(
      text: widget.role == 'petugas'
          ? (user?['name'] ?? '')
          : (tenant?['tenant_name'] ?? ''),
    );
    phoneController = TextEditingController(
      text: widget.role == 'petugas'
          ? (user?['phone_number'] ?? '')
          : (tenant?['contact_phone'] ?? ''),
    );
    picController = TextEditingController(
      text: tenant?['person_in_charge'] ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    picController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);

    Map<String, dynamic> data = {
      'name': nameController.text,
      'phone_number': phoneController.text,
      'role': widget.role,
    };

    if (widget.role == 'tenant') {
      data.addAll({
        'tenant_name': nameController.text,
        'contact_phone': phoneController.text,
        'person_in_charge': picController.text,
      });
    }

    bool success = await widget.api.updateProfile(data, widget.token);

    if (mounted) {
      setState(() => isSaving = false);
      if (success) {
        setState(() => isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui. Periksa koneksi atau data Anda."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogout() async {
    if (!showLogoutConfirm) {
      setState(() => showLogoutConfirm = true);
    } else {
      await widget.api.logout(widget.token);
      await SessionService.clearSession(); // ← add this
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) =>
              false, // clears entire stack so back button can't return to dashboard
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.api.currentUser;
    final tenant = user?['tenant_details'];
    final bool isPetugas = widget.role == 'petugas';

    final String displayName = isPetugas
        ? (user?['name'] ?? '-')
        : (tenant?['tenant_name'] ?? '-');
    final String displayUsername =
        "@${(user?['username'] ?? user?['name'] ?? '-').toString().replaceFirst('@', '')}";

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Edit Profil" : "Profil Akun",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isEditing) _initFields();
                      setState(() => isEditing = !isEditing);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        isEditing ? Icons.close : Icons.edit,
                        color: AppColors.primaryOrange.withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar + name row (from AccountModalTenant style)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF7D1C0A), Color(0xFFFA6C2A)],
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 23,
                      backgroundColor: Color(0xFFD2B4A6),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF7A4A32),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        displayUsername,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 12),

              if (!isEditing) ...[
                // View mode
                if (isPetugas) ...[
                  _buildInfoRow("Nama", user?['name']),
                  _buildInfoRow("Username", user?['username'] ?? user?['name']),
                  _buildInfoRow("Email", user?['email']),
                  _buildInfoRow("Telepon", user?['phone_number']),
                ] else ...[
                  _buildInfoRow("Nama Tenant", tenant?['tenant_name']),
                  _buildInfoRow("PIC", tenant?['person_in_charge']),
                  _buildInfoRow("Telepon", tenant?['contact_phone']),
                  _buildInfoRow("Perusahaan", tenant?['company_name']),
                ],

                const SizedBox(height: 28),

                // --- Combined Logout / Confirmation Logic ---
                if (showLogoutConfirm) ...[
                  Text(
                    "Apakah Anda yakin ingin keluar?",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOutlineButton(
                          label: "Ya, Keluar",
                          icon: Icons.check,
                          color: const Color(0xFFE57373),
                          onTap:
                              _handleLogout, // This now triggers the actual logout
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOutlineButton(
                          label: "Batal",
                          icon: Icons.close,
                          color: Colors.white54,
                          onTap: () =>
                              setState(() => showLogoutConfirm = false),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Original Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildOutlineButton(
                          label: "Keluar",
                          icon: Icons.logout,
                          color: const Color(0xFFE57373),
                          onTap:
                              _handleLogout, // This now toggles the confirm state
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOutlineButton(
                          label: "Tutup",
                          icon: Icons.close,
                          color: Colors.white54,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                // Edit mode
                _buildTextField(
                  isPetugas ? "Nama Lengkap" : "Nama Tenant",
                  nameController,
                ),
                _buildTextField(
                  isPetugas ? "Nomor Telepon" : "Telepon Kontak",
                  phoneController,
                ),
                if (!isPetugas)
                  _buildTextField("Penanggung Jawab", picController),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.9,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white54, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
