import 'package:flutter/material.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'input_reading_screen.dart';

// Kita pakai variabel global di dalam file ini untuk mencatat unit mana saja yang sudah kelar
// Key: "${unitId}_${category}", Value: bool
Map<String, bool> globalSessionTracker = {};

class SuccessReadingScreen extends StatelessWidget {
  final Unit unit;
  final String completedCategory; 
  final bool isEdit;

  const SuccessReadingScreen({
    super.key,
    required this.unit,
    required this.completedCategory,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF723CFF);

    // Tandai kategori ini sebagai "Sudah Diisi" untuk unit ini
    globalSessionTracker["${unit.id}_$completedCategory"] = true;

    // Tentukan apa kategori lawannya
    String otherCategory = (completedCategory == 'Electric') ? 'Water' : 'Electric';

    // Cek apakah lawan kategorinya sudah pernah diisi di sesi ini
    bool isOtherAlreadyFilled = globalSessionTracker["${unit.id}_$otherCategory"] ?? false;

    // JANGAN munculkan prompt kalau: sedang edit, atau lawannya sudah diisi
    bool shouldShowPrompt = !isEdit && !isOtherAlreadyFilled;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildSuccessIcon(),
              const SizedBox(height: 24),
              Text(
                "Unit ${unit.unitNumber} - ${completedCategory == 'Electric' ? 'Listrik' : 'Air'}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text("Data berhasil diverifikasi dan disimpan.", style: TextStyle(color: Colors.grey)),
              const Spacer(),

              if (shouldShowPrompt) ...[
                _buildPromptCard(context, otherCategory, accentColor),
                const SizedBox(height: 16),
              ],

              _buildBackButton(context, accentColor, shouldShowPrompt),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
    );
  }

  Widget _buildPromptCard(BuildContext context, String category, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF4E7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text("Meteran $category belum diisi!", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InputReadingScreen(unit: unit, category: category)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("INPUT $category SEKARANG"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, Color color, bool isPending) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context, true),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(isPending ? "NANTI SAJA" : "SELESAI", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}