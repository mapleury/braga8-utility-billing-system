import 'package:flutter/material.dart';
import 'package:braga8_mobile/ApiService.dart';

void showProfileModal(BuildContext context, ApiService api, String role, String token) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => ProfileControllerSheet(api: api, role: role, token: token),
  );
}

class ProfileControllerSheet extends StatefulWidget {
  final ApiService api;
  final String role;
  final String token;

  const ProfileControllerSheet({super.key, required this.api, required this.role, required this.token});

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

    // Initialize with fallbacks to avoid null errors
    nameController = TextEditingController(
      text: widget.role == 'petugas' ? (user?['name'] ?? '') : (tenant?['tenant_name'] ?? '')
    );
    phoneController = TextEditingController(
      text: widget.role == 'petugas' ? (user?['phone_number'] ?? '') : (tenant?['contact_phone'] ?? '')
    );
    picController = TextEditingController(text: tenant?['person_in_charge'] ?? '');
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

    // CRITICAL: Added 'role' so Laravel validation works
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
          const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update Failed. Check API validation."), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.api.currentUser;
    final tenant = user?['tenant_details'];
    final bool isPetugas = widget.role == 'petugas';

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEditing ? "Edit Profile" : "Account Profile", 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
              IconButton(
                icon: Icon(isEditing ? Icons.cancel : Icons.edit, color: Colors.indigo),
                onPressed: () {
                  if (isEditing) _initFields(); // Reset fields if canceling
                  setState(() => isEditing = !isEditing);
                },
              )
            ],
          ),
          const Divider(),

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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ),
          ] else ...[
            // --- EDIT MODE ---
            _buildTextField(isPetugas ? "Full Name" : "Tenant Name", nameController),
            _buildTextField(isPetugas ? "Phone Number" : "Contact Phone", phoneController),
            if (!isPetugas) _buildTextField("Person In Charge", picController),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}