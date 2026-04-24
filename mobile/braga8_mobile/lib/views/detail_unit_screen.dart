import 'dart:typed_data';
import 'package:braga8_mobile/views/input_reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'package:braga8_mobile/components/header_unit_detail_card_component.dart';
import 'package:braga8_mobile/components/image_container_proof_component.dart';
import 'package:braga8_mobile/components/image_detail_card_component.dart';

class DetailUnitScreen extends StatefulWidget {
  final String shopName;
  final Unit unit;

  const DetailUnitScreen({
    super.key,
    required this.shopName,
    required this.unit,
  });

  @override
  State<DetailUnitScreen> createState() => _DetailUnitScreenState();
}

class _DetailUnitScreenState extends State<DetailUnitScreen> {
  String selectedCategory = "Electric";

  @override
  Widget build(BuildContext context) {
    // Gunakan IP lokal yang sesuai dengan koneksi backend lo
    const String apiImageUrl = "http://127.0.0.1:8000/api/meter-photo/";
    final bool isElectric = selectedCategory == "Electric";

    // --- 1. LOGIC DATA CURRENT (Dinamis sesuai Category) ---
    final String? readingValue = isElectric
        ? widget.unit.elecReadingValue
        : widget.unit.waterReadingValue;

    final String? recordedDate = isElectric
        ? widget.unit.elecRecordedAt
        : widget.unit.waterRecordedAt;

    // Ambil lokasi spesifik meteran atau fallback ke alamat unit
    final String? currentLocation = isElectric
        ? (widget.unit.elecLocationAddress ?? widget.unit.locationAddress)
        : (widget.unit.waterLocationAddress ?? widget.unit.locationAddress);

    final String? rawPath = isElectric
        ? widget.unit.elecPhotoPath
        : widget.unit.waterPhotoPath;

    final String? currentPhotoUrl = (rawPath != null && rawPath.isNotEmpty)
        ? "$apiImageUrl${rawPath.split('/').last}"
        : null;

    // --- 2. LOGIC DATA PREVIOUS (Dinamis sesuai Category) ---
    final String? prevReadingValue = isElectric
        ? widget.unit.prevElecReadingValue
        : widget.unit.prevWaterReadingValue;

    final String? prevRecordedDate = isElectric
        ? widget.unit.prevElecRecordedAt
        : widget.unit.prevWaterRecordedAt;

    final String? prevRawPath = isElectric
        ? widget.unit.prevElecPhotoPath
        : widget.unit.prevWaterPhotoPath;

    final String? prevPhotoUrl = (prevRawPath != null && prevRawPath.isNotEmpty)
        ? "$apiImageUrl${prevRawPath.split('/').last}"
        : null;

    final bool hasData = readingValue != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          "Unit Detail",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card dengan Toggle Category
            HeaderUnitDetailCardComponent(
              unitNumber: widget.unit.unitNumber,
              tenantName: widget.shopName,
              electricMeter: widget.unit.electricMeterNumber ?? "No Meter",
              waterMeter: widget.unit.waterMeterNumber ?? "No Meter",
              category: selectedCategory,
              onCategoryToggle: () {
                setState(() {
                  selectedCategory = isElectric ? "Water" : "Electric";
                });
              },
            ),

            const SizedBox(height: 30),

            if (!hasData) ...[
              _buildEmptyState(),
            ] else ...[
              // Display Angka Meteran Saat Ini
              _buildReadingDisplay(isElectric, readingValue),

              const SizedBox(height: 30),
              const Text(
                "Photo Proof",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Container Foto (Kiri: Current, Kanan: Previous)
              ImageContainerProofComponent(
                currentImageUrl: currentPhotoUrl,
                previousImageUrl: prevPhotoUrl,
              ),

              const SizedBox(height: 30),
              const Text(
                "Entry Metadata",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Metadata yang sekarang FULL DINAMIS (Tanggal & Lokasi)
              // Di dalam build() DetailUnitScreen lo:
              ImageDetailCardComponent(
                inputDate:
                    recordedDate, // Pakai recordedDate yang sudah dipilih lewat isElectric logic
                category: selectedCategory, // "Electric" atau "Water"
                location: isElectric
                    ? widget.unit.elecLocationAddress
                    : widget.unit.waterLocationAddress,
              ),
            ],

            const SizedBox(height: 40),

            // Tombol Aksi
            _buildActionButton(hasData),
            const SizedBox(height: 12),
            _buildBackButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 70,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              "No Data Recorded",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please perform a meter reading for this unit.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingDisplay(bool isElectric, String readingValue) {
    return Center(
      child: Column(
        children: [
          Text(
            isElectric
                ? "Current Electricity Reading"
                : "Current Water Reading",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            isElectric ? "$readingValue kWh" : "$readingValue m³",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF723CFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool hasData) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Tentukan nilai awal jika sedang mode Edit
          final String? initialValue = selectedCategory == "Electric"
              ? widget.unit.elecReadingValue
              : widget.unit.waterReadingValue;

          // Navigasi ke InputReadingScreen yang baru kita buat
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputReadingScreen(
                unit: widget.unit,
                category: selectedCategory, // "Electric" atau "Water"
                isEdit: hasData, // True jika sudah ada data meteran
                initialValue: initialValue, // Isi form otomatis jika Edit
              ),
            ),
          );

          // Jika result true (berhasil simpan), lo bisa trigger refresh data di sini
          if (result == true) {
            // Contoh: panggil fungsi fetch ulang atau setState
            debugPrint("Data berhasil disimpan, saatnya refresh UI!");
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF723CFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          hasData ? "Edit Reading" : "Input New Reading",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFF723CFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Kembali",
          style: TextStyle(
            color: Color(0xFF723CFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
