import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';

class InputReadingScreen extends StatefulWidget {
  final Unit unit;
  final String category; // "Electric" atau "Water"
  final bool isEdit;
  final String? initialValue;

  const InputReadingScreen({
    super.key,
    required this.unit,
    required this.category,
    this.isEdit = false,
    this.initialValue,
  });

  @override
  State<InputReadingScreen> createState() => _InputReadingScreenState();
}

class _InputReadingScreenState extends State<InputReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descController = TextEditingController();
  final ApiService _apiService = ApiService();

  File? _image;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _valueController.text = widget.initialValue ?? "";
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null && !widget.isEdit) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Foto bukti wajib ada!")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Get Current Location
      Position position = await _apiService.determinePosition();

      // 2. Prepare Data
      final Map<String, dynamic> data = {
        'unit_id': widget.unit.id,
        'meter_type': widget.category.toLowerCase(),
        'reading_value': _valueController.text,
        'description': _descController.text,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      // 3. Send to API
      // Note: Di backend lo harus handle Multipart jika ada image
      bool success = await _apiService.submitMeterReading(data, _image);

      if (success && mounted) {
        Navigator.pop(context, true); // Kembali ke Detail dengan flag success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.category} data saved successfully!"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit
              ? "Edit ${widget.category}"
              : "New ${widget.category} Reading",
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Unit
              Text(
                "Unit ${widget.unit.unitNumber}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Input Angka
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      "Meter Value (${widget.category == 'Electric' ? 'kWh' : 'm³'})",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.speed),
                ),
                validator: (v) => v!.isEmpty ? "Input value is required" : null,
              ),

              const SizedBox(height: 20),

              // Input Deskripsi
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Notes / Description (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Camera Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                            Text("Tap to capture meter photo"),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF723CFF),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isEdit ? "Update Reading" : "Submit Reading",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
