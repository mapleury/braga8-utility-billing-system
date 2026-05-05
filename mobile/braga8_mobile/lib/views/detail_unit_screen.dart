import 'package:braga8_mobile/views/meter_reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/views/input_reading_screen.dart';
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
  late Unit currentUnit;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Inisialisasi state awal pakai data dari halaman sebelumnya
    currentUnit = widget.unit;
  }

  // --- LOGIC REFRESH DATA ---
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      // Panggil API untuk ambil data terbaru
      final tenants = await _apiService.fetchUnitsSummary();

      // Cari unit yang sesuai dengan ID saat ini
      for (var tenant in tenants) {
        try {
          final updatedUnit = tenant.units.firstWhere(
            (u) => u.id == currentUnit.id,
          );
          setState(() {
            currentUnit = updatedUnit;
          });
          break; // Stop looping kalau unit sudah ketemu
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint("Gagal me-refresh data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui data dari server")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const String apiImageUrl =
        "https://bunkbed-deem-spew.ngrok-free.dev/api/meter-photo/";
    final bool isElectric = selectedCategory == "Electric";

    // --- 1. LOGIC DATA CURRENT (Pakai currentUnit) ---
    final String? readingValue = isElectric
        ? currentUnit.elecReadingValue
        : currentUnit.waterReadingValue;

    final String? recordedDate = isElectric
        ? currentUnit.elecRecordedAt
        : currentUnit.waterRecordedAt;

    final String? currentLocation = isElectric
        ? (currentUnit.elecLocationAddress ?? currentUnit.locationAddress)
        : (currentUnit.waterLocationAddress ?? currentUnit.locationAddress);

    final String? rawPath = isElectric
        ? currentUnit.elecPhotoPath
        : currentUnit.waterPhotoPath;

    final String? currentPhotoUrl = (rawPath != null && rawPath.isNotEmpty)
        ? "$apiImageUrl${rawPath.split('/').last}"
        : null;

    // --- 2. LOGIC DATA PREVIOUS (Pakai currentUnit) ---
    final String? prevReadingValue = isElectric
        ? currentUnit.prevElecReadingValue
        : currentUnit.prevWaterReadingValue;

    final String? prevRecordedDate = isElectric
        ? currentUnit.prevElecRecordedAt
        : currentUnit.prevWaterRecordedAt;

    final String? prevRawPath = isElectric
        ? currentUnit.prevElecPhotoPath
        : currentUnit.prevWaterPhotoPath;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
            tooltip: "Refresh Data",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF723CFF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  HeaderUnitDetailCardComponent(
                    unitNumber: currentUnit.unitNumber,
                    tenantName: widget.shopName,
                    electricMeter:
                        currentUnit.electricMeterNumber ?? "No Meter",
                    waterMeter: currentUnit.waterMeterNumber ?? "No Meter",
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
                    _buildReadingDisplay(isElectric, readingValue),

                    const SizedBox(height: 30),
                    const Text(
                      "Photo Proof",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    ImageContainerProofComponent(
                      currentImageUrl: currentPhotoUrl,
                      previousImageUrl: prevPhotoUrl,
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Entry Metadata",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    ImageDetailCardComponent(
                      inputDate: recordedDate,
                      category: selectedCategory,
                      location: currentLocation,
                    ),
                  ],

                  const SizedBox(height: 40),

                  _buildActionButton(hasData),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  _buildHistoryButton(),
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
          final String? initialValue = selectedCategory == "Electric"
              ? currentUnit.elecReadingValue
              : currentUnit.waterReadingValue;

          // Navigasi ke form input dan tunggu hasilnya
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputReadingScreen(
                unit: currentUnit, // Lempar currentUnit terbaru
                category: selectedCategory,
                isEdit: hasData,
                initialValue: initialValue,
              ),
            ),
          );

          // Jika form mengembalikan true (sukses simpan), panggil refresh!
          if (result == true) {
            _refreshData();
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

  Widget _buildHistoryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeterHistoryScreen(
                unitId: currentUnit.id,
                unitNumber: currentUnit.unitNumber,
              ),
            ),
          );
        },
        icon: const Icon(Icons.history, color: Color(0xFF723CFF)),
        label: const Text(
          "Lihat Riwayat Bacaan",
          style: TextStyle(
            color: Color(0xFF723CFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFF723CFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
