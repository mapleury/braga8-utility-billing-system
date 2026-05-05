import 'dart:ui';
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
    // Background transparan agar efek blur BackdropFilter terlihat
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
            content: Text("Profile Updated!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Update Failed. Check API validation."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.api.currentUser;
    final tenant = user?['tenant_details'];
    final bool isPetugas = widget.role == 'petugas';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek Glassmorphism
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            // Black soft transparent background
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15), // Apple soft border
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
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

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Edit Profile" : "Account Profile",
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

              if (!isEditing) ...[
                // --- VIEW MODE ---
                if (isPetugas) ...[
                  _buildInfoRow("Name", user?['name']),
                  _buildInfoRow("Username", user?['username'] ?? user?['name']),
                  _buildInfoRow("Email", user?['email']),
                  _buildInfoRow("Phone", user?['phone_number']),
                ] else ...[
                  _buildInfoRow("Tenant Name", tenant?['tenant_name']),
                  _buildInfoRow("PIC", tenant?['person_in_charge']),
                  _buildInfoRow("Phone", tenant?['contact_phone']),
                  _buildInfoRow("Company", tenant?['company_name']),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.9,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // --- EDIT MODE ---
                _buildTextField(
                  isPetugas ? "Full Name" : "Tenant Name",
                  nameController,
                ),
                _buildTextField(
                  isPetugas ? "Phone Number" : "Contact Phone",
                  phoneController,
                ),
                if (!isPetugas)
                  _buildTextField("Person In Charge", picController),

                const SizedBox(height: 32),
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
                      padding: const EdgeInsets.symmetric(vertical: 18),
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

  // --- WIDGET HELPERS ---

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05), // Input bg
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
            borderSide: BorderSide(color: Colors.white54, width: 1.5),
          ),
        ),
      ),
    );
  }
}
